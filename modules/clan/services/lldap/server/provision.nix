{lib, ...}: let
  inherit (lib) mkOption types;
in {
  roles.server = {
    description = "lldap server";
    interface = {...}: let
      ensureFieldsOptions = name: {
        name = mkOption {
          type =
            types.strMatching "[a-zA-Z0-9_-]+";
          description = "Name of the field.";
          default = name;
        };

        attributeType = mkOption {
          type = types.enum [
            "STRING"
            "INTEGER"
            "JPEG"
            "DATE_TIME"
          ];
          description = "Attribute type.";
        };

        isEditable = mkOption {
          type = types.bool;
          description = "Is field editable.";
          default = true;
        };

        isList = mkOption {
          type = types.bool;
          description = "Is field a list.";
          default = false;
        };

        isVisible = mkOption {
          type = types.bool;
          description = "Is field visible in UI.";
          default = true;
        };
      };
    in {
      options = {
        ensureUserFields = mkOption {
          description = "Extra fields for users";
          default = {};
          type = types.attrsOf (
            types.submodule (
              {name, ...}: {
                options = ensureFieldsOptions name;
              }
            )
          );
        };

        ensureGroupFields = mkOption {
          description = "Extra fields for groups";
          default = {};
          type = types.attrsOf (
            types.submodule (
              {name, ...}: {
                options = ensureFieldsOptions name;
              }
            )
          );
        };

        enforceUsers = mkOption {
          description = "Delete users not managed declaratively.";
          type = types.bool;
          default = false;
        };

        enforceUserMemberships = mkOption {
          description = "Remove users from groups they do not belong to declaratively.";
          type = types.bool;
          default = false;
        };

        enforceGroups = mkOption {
          description = "Delete groups not managed declaratively.";
          type = types.bool;
          default = false;
        };
      };
    };
    perInstance = {
      settings,
      roles,
      ...
    }: let
      extractExtra = extra: v:
        (lib.pipe v.extraFields [
          (lib.mapAttrsToList (n: v: let
            var = extra."${n}" or null;
            testFu = val: let
              bool =
                if var.attributeType == "INTEGER"
                then lib.isInt val
                else lib.isString val;
            in
              if bool
              then bool
              else throw "Types doesnt match";
          in
            if var != null
            then {
              name = n;
              value = (
                if var.isList && lib.isList v
                then testFu (lib.head v)
                else if var.isList
                then throw "Value is not a list"
                else testFu v
              );
            }
            else throw "Field doesnt exist"))
          lib.listToAttrs
        ])
        // (
          lib.pipe v.extraFields [
            lib.attrNames
            (lib.removeAttrs extra)
            (lib.mapAttrs (_: v:
              if v.isList
              then []
              else null))
          ]
        );
      ensure = lib.pipe roles.client.machines [
        lib.attrValues
        (map (x: {inherit (x.settings) ensureUsers ensureGroups;}))
        (map (lib.mapAttrs (n: v: let
          extra =
            if lib.hasSuffix "Users" n
            then settings.ensureUserFields
            else settings.ensureGroupFields;
        in
          lib.mapAttrsToList (n: v: {
            name = n;
            value =
              (lib.removeAttrs v ["extraFields"])
              // (extractExtra extra v);
          })
          v)))
        lib.zipAttrs
        (lib.mapAttrs (_: v:
          lib.listToAttrs
          (lib.flatten v)))
      ];
      inherit (ensure) ensureUsers ensureGroups;

      allUserGroups = lib.flatten (lib.mapAttrsToList (n: u: u.groups) ensureUsers);
      # # The three hardcoded groups are always created when the service starts.
      allGroups =
        lib.mapAttrsToList (_: g: g.name) ensureGroups
        ++ [
          "lldap_admin"
          "lldap_password_manager"
          "lldap_strict_readonly"
        ];
      userGroupNotInEnsuredGroup = lib.sortOn lib.id (
        lib.unique (lib.subtractLists allGroups allUserGroups)
      );
      someUsersBelongToNonEnsuredGroup = (lib.lists.length userGroupNotInEnsuredGroup) > 0;
    in {
      nixosModule = {
        lib,
        config,
        pkgs,
        ...
      }: let
        ensureFormat = pkgs.formats.json {};
        bootstrapPkg = pkgs.callPackage ../package/default.nix {};
        ensureGenerate = let
          filterNulls = lib.filterAttrsRecursive (n: v: v != null);

          filteredSource = source:
            if builtins.isList source
            then map filterNulls source
            else filterNulls source;
        in
          name: source: ensureFormat.generate name (filteredSource source);
        generateEnsureConfigDir = name: source: let
          genOne = name: sourceOne:
            pkgs.writeTextDir "configs/${name}.json" (
              builtins.readFile (ensureGenerate "configs/${name}.json" sourceOne)
            );

          paths = lib.mapAttrsToList genOne source;

          link = pkgs.symlinkJoin {
            inherit name paths;
          };
        in
          if lib.length paths == 0
          then "/dev/null"
          else "${link}/configs";

        quoteVariable = x: "\"${x}\"";
        cfg = config.services.lldap;
      in {
        # clan =
        assertions = [
          {
            assertion = settings.enforceUserMemberships -> !someUsersBelongToNonEnsuredGroup;
            message = ''
              lldap: Some users belong to groups not present in the ensureGroups attr,
              add the following groups or remove them from the groups a user belong to:
                ${lib.concatMapStringsSep quoteVariable ", " userGroupNotInEnsuredGroup}
            '';
          }
        ];
        #
        # warnings =
        #   (lib.optionals (cfg.settings.ldap_user_pass or null != null) [
        #     ''
        #       lldap: Unsecure `ldap_user_pass` setting is used. Prefer `ldap_user_pass_file` instead.
        #     ''
        #   ])
        #   ++ (
        #     lib.optionals
        #     (cfg.settings.force_ldap_user_pass_reset == false && cfg.silenceForceUserPassResetWarning == false)
        #     [
        #       ''
        #         lldap: The `force_ldap_user_pass_reset` setting is set to `false` which means
        #         the admin password can be changed through the UI and will drift from the one defined in your nix config.
        #         It also means changing the setting `ldap_user_pass` or `ldap_user_pass_file` will have no effect on the admin password.
        #         Either set `force_ldap_user_pass_reset` to `"always"` or silence this warning by setting the option `services.lldap.silenceForceUserPassResetWarning` to `true`.
        #       ''
        #     ]
        #   )
        #   ++ (lib.optionals (!settings.enforceUserMemberships && someUsersBelongToNonEnsuredGroup) [
        #     ''
        #       Some users belong to groups not managed by the configuration here,
        #       make sure the following groups exist or the service will not start properly:
        #         ${lib.concatStringsSep ", " (map (x: "\"${x}\"") userGroupNotInEnsuredGroup)}
        #     ''
        #   ]);

        systemd.services.lldap = {
          serviceConfig = {
            ExecStartPost = "+${pkgs.writeShellScript "bootstrap.sh" ''

              export LLDAP_URL=http://127.0.0.1:${toString cfg.settings.http_port}
              export LLDAP_ADMIN_USERNAME=${cfg.settings.ldap_user_dn}
              export LLDAP_ADMIN_PASSWORD_FILE=${config.clan.core.vars.generators."ldap".files."password".path}
              export USER_CONFIGS_DIR=${lib.traceVal (
                generateEnsureConfigDir "users"
                (lib.mapAttrs (n: v:
                  v
                  // {
                    password_file = config.clan.core.vars.generators.lldap-passwords.files."${n}".path;
                  })
                ensureUsers)
              )}
              export GROUP_CONFIGS_DIR=${generateEnsureConfigDir "groups" ensureGroups}
              export USER_SCHEMAS_DIR=${
                generateEnsureConfigDir "userFields" (lib.mapAttrs (n: v: [v]) settings.ensureUserFields)
              }
              export GROUP_SCHEMAS_DIR=${
                generateEnsureConfigDir "groupFields" (lib.mapAttrs (n: v: [v]) settings.ensureGroupFields)
              }
              export DO_CLEANUP_USERS=${
                if settings.enforceUsers
                then "true"
                else "false"
              }
              export DO_CLEANUP_USER_MEMBERSHIPS=${
                if settings.enforceUserMemberships
                then "true"
                else "false"
              }
              export DO_CLEANUP_GROUPS=${
                if settings.enforceGroups
                then "true"
                else "false"
              }

              ${bootstrapPkg}/bin/lldap-bootstrap

            ''}";
          };
        };
      };
    };
  };
}
