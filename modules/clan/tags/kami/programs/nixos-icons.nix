{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.nixos-icons;
in {
  options.nixos-icons = {
    white = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    colours = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };
  config. 
      nixpkgs.overlays = [
    (self: super: {
      nixos-icons = super.nixos-icons.overrideAttrs (oldAttrs: {
        src = pkgs.applyPatches {
          inherit (oldAttrs) src;
          prePatch = ''
            ${
              if cfg.white != null
              then "cp ${cfg.white} logo/nix-snowflake-white.svg"
              else ""
            }
            ${
              if cfg.colours != null
              then "cp ${cfg.colours} logo/nix-snowflake-colours.svg"
              else ""
            }
          '';
        };
      });
    })
  ];
}
