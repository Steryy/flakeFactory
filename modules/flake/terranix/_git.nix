{
  lib,
  config,
  ...
}: let
  getAddress = cfg: "http://localhost:${toString cfg.port}/?type=git&repository=${cfg.user}@${cfg.host}:${cfg.owner}/${cfg.repo}&ref=${cfg.ref}&state=${cfg.path}";

  gitSubmodule = with lib;
    types.submodule ({config, ...}: {
      config = lib.mkMerge [
        (lib.mkIf (config.type == "github") {
          host = "github.com";
          user = "git";
        })
      ];
      options = {
        repo = mkOption {
          type = with types; str;
        };
        owner = mkOption {
          type = with types; str;
        };
        user = mkOption {
          type = with types; str;
        };
        port = mkOption {
          type = with types; int;
          default = 6061;
        };
        ref = mkOption {
          type = with types; str;
          default = "terraform";
        };
        host = mkOption {
          type = with types; str;
        };
        type = mkOption {
          type = with types; enum ["github" "gitlab" "gitea" "forgejo" "custom"];
          default = "github";
        };
        path = mkOption {
          type = with types; str;
          default = "state.json";
        };
      };
    });
in {
  options.backend.git = lib.mkOption {
    default = null;
    type = with lib.types; nullOr gitSubmodule;
  };
  options.remote_state.git = {
    default = {};
    type = with lib.types; attrsOf (gitSubmodule);
  };
  config = let
    backend = lib.mkIf (config.backend.git != null) {
      terraform.backend.http = let
        adr = getAddress config.backend.git;
      in {
        address = adr;
        lock_address = adr;
        unlock_address = adr;
      };
    };

    remote = lib. mkIf (config.remote_state.git != {}) {
      data."terraform_remote_state" =
        lib. mapAttrs
        (name: value: {
          config = {
            address = getAddress value;
          };
          backend = "http";
        })
        config.remote_state.git;
    };
  in
    lib.mkMerge [
      backend
      # remote
    ];
}
