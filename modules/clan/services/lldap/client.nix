{
  roles.client = {
    interface = {lib, ...}: let
      inherit (lib) mkOption types;
      t = types.oneOf [
        types.bool
        types.int
        types.float
        types.str
        types.path
      ];
      valueType =
        types.nullOr (types.oneOf [
          t
          (types.listOf t)
        ])
        // {
          description = "JSON value";
        };
    in {
      options = {
        ensureUsers = mkOption {
          description = ''
            Create the users defined here on service startup.

            If `enforceEnsure` option is `true`, the groups
            users belong to must be present in the `ensureGroups` option.

            Non-default options must be added to the `ensureGroupFields` option.
          '';
          default = {};
          type = types.attrsOf (
            types.submodule (
              {name, ...}: {
                options = {
                  extraFields = mkOption {
                    default = {};
                    type = types.attrsOf valueType;
                  };
                  id = mkOption {
                    type = types.strMatching "[a-zA-Z0-9_-]+";
                    description = "Username.";
                    default = name;
                  };

                  email = mkOption {
                    type = types.str;
                    description = "Email.";
                  };

                  displayName = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Display name.";
                  };

                  firstName = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "First name.";
                  };

                  lastName = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Last name.";
                  };

                  avatar_file = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Avatar file. Must be a valid path to jpeg file (ignored if avatar_url specified)";
                  };

                  avatar_url = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Avatar url. must be a valid URL to jpeg file (ignored if gravatar_avatar specified)";
                  };

                  gravatar_avatar = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Get avatar from Gravatar using the email.";
                  };

                  weser_avatar = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Convert avatar retrieved by gravatar or the URL.";
                  };

                  groups = mkOption {
                    type = types.listOf types.str;
                    default = [];
                    description = "Groups the user would be a member of (all the groups must be specified in group config files).";
                  };
                };
              }
            )
          );
        };

        ensureGroups = mkOption {
          description = ''
            Create the groups defined here on service startup.

            Non-default options must be added to the `ensureGroupFields` option.
          '';
          default = {};
          type = types.attrsOf (
            types.submodule (
              {name, ...}: {
                options = {
                  extraFields = mkOption {
                    default = {};
                    type = types.attrsOf valueType;
                  };
                  name = mkOption {
                    type = types.strMatching "[a-zA-Z0-9_-]+";
                    description = "Name of the group.";
                    default = name;
                  };
                };
              }
            )
          );
        };
      };
    };
  };
}
