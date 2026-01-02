{lib, ...}: let
  createTokens = files: pkgs: (lib.mapAttrs' (n: _: {
      name = "rathole-${n}";
      value = {
        share = true;
        runtimeInputs = with pkgs; [
          openssl
        ];
        files.token = {
          deploy = false;
        };

        script =
          #bash
          ''openssl rand -base64 32 | tr -d '\n' | tr -d ' ' >  "$out/token" '';
      };
    })
    files);
in {
  _class = "clan.service";
  manifest.name = "@local/rathole";
  manifest.readme = ./readme.md;
  manifest.description = "Rust reverse proxy";
  roles.server = {
    description = "Server to use for reverse proxy";
    interface = {lib, ...}: {
      options = {
        hostname = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        openFirewall = lib.mkEnableOption "Open firewall for clients services";
        port = lib.mkOption {
          type = lib.types.int;
          default = 5202;
          description = "";
        };
      };
    };
    perInstance = {
      settings,
      roles,
      lib,
      machine,
      ...
    }: let
      serverlength = lib.length (lib.attrNames roles.server.machines);
      clients =
        lib.filterAttrs (
          _: v:
            machine.name
            == v.settings.server
            || serverlength == 1
        )
        roles.client.machines;
      allservices = lib.pipe clients [
        lib.attrValues
        (
          map (x: lib.attrsToList (x.settings.services))
        )
        lib.flatten
        lib.listToAttrs
      ];

      files = lib.pipe allservices [
        (lib.filterAttrs (n: v: v.createToken))
        (lib.mapAttrs (_: _: {
          deploy = false;
        }))
      ];
    in {
      nixosModule = {
        lib,
        pkgs,
        config,
        ...
      }: {
        networking.firewall.allowedTCPPorts =
          [settings.port]
          ++ (
            lib.optionals (settings.openFirewall) (
              lib.pipe allservices [
                lib.attrValues
                (lib.filter (x: x.type == "tcp" && x.openRemote))
                (map (x: x.remotePort))
              ]
            )
          );
        networking.firewall.allowedUDPPorts = lib.optionals (settings.openFirewall) (
          lib.pipe allservices [
            lib.attrValues
            (lib.filter (x: x.type == "udp" && x.openRemote))
            (map (x: x.remotePort))
          ]
        );

        clan.core.vars.generators =
          (createTokens files pkgs)
          // {
            rathole-server = {
              files = {"tokens.toml" = {};};

              dependencies = lib.mapAttrsToList (n: _: "rathole-${n}") files;
              runtimeInputs = with pkgs; [
                yj
              ];
              script = ''
                echo "${lib.replaceStrings ["\""] ["\\\""] (builtins.toJSON {
                  server.services =
                    lib.mapAttrs (n: _: {
                      token = "$(cat $in/rathole-${n}/token)";
                    })
                    files;
                })}" | yj -jt > "$out/tokens.toml"

              '';
            };
          };

        services.rathole = {
          enable = true;
          role = "server";

          credentialsFile = config.clan.core.vars.generators.rathole-server.files."tokens.toml".path;
          settings = {
            server = {
              bind_addr = "0.0.0.0:${toString settings.port}";

              services =
                lib.mapAttrs (
                  n: v: {
                    bind_addr = "0.0.0.0:${toString v.remotePort}";
                    type = v.type;
                  }
                )
                allservices;
            };
          };
        };
      };
    };
  };

  roles.client = {
    description = "Client that will connect to rathole server";
    interface = {lib, ...}: {
      options = {
        server = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Which server clients should choose. If there is only one this option can be null";
        };
        services = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule ({config, ...}: {
              options = {
                type = lib.mkOption {
                  type = lib.types.enum ["tcp" "udp"];
                  default = "tcp";
                };
                host = lib.mkOption {
                  type =
                    lib.types.str;
                  default = "localhost";
                };

                createToken = lib.mkEnableOption "Whether enable creating token fot this service";
                openRemote = lib.mkEnableOption "Whether to enable opening on remote";
                remotePort = lib.mkOption {
                  type = lib.types.int;
                  default = config.port;
                  description = "Port of the service to reverse proxy";
                };
                port = lib.mkOption {
                  type = lib.types.int;
                  default = 5202;
                  description = "Port of the service to reverse proxy";
                };
              };
            })
          );
        };
      };
    };
    perInstance = {
      settings,
      roles,
      lib,
      ...
    }: let
      servers = roles.server.machines;
      servername =
        if settings.server == null
        then
          (
            if builtins.length (lib.attrNames servers) == 1
            then lib.head (lib.attrNames servers)
            else throw "you must choose server if you have more than 1"
          )
        else servers."${settings.server}";
      server = servers."${servername}".settings;
    in {
      nixosModule = {
        config,
        pkgs,
        ...
      }: let
        files = lib.pipe settings.services [
          (lib.filterAttrs (n: v: v.createToken))
          (lib.mapAttrs (_: _: {
            }))
        ];
      in {
        clan.core.vars.generators =
          (createTokens files pkgs)
          // {
            rathole-client = {
              files = {"tokens.toml" = {};};

              dependencies = lib.mapAttrsToList (n: _: "rathole-${n}") files;
              runtimeInputs = with pkgs; [
                yj
              ];
              script = ''
                echo "${lib.replaceStrings ["\""] ["\\\""] (builtins.toJSON {
                  client.services =
                    lib.mapAttrs (n: _: {
                      token = "$(cat $in/rathole-${n}/token)";
                    })
                    files;
                })}" | yj -jt > "$out/tokens.toml"

              '';
            };
          };

        services.rathole = {
          enable = true;
          role = "client";
          credentialsFile = config.clan.core.vars.generators.rathole-client.files."tokens.toml".path;
          settings = {
            client = {
              remote_addr = "${server.hostname}:${toString server.port}";
              services =
                lib.mapAttrs (
                  n: v: {
                    local_addr = "${v.host}:${toString v.port}";
                    type = v.type;
                  }
                )
                settings.services;
            };
          };
        };
      };
    };
  };
}
