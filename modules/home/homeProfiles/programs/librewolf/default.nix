{ pkgs, lib, options, inputs, config, ... }:
let
  args = { inherit pkgs lib inputs config; };
  settings = import ./_settings.nix;
  floorpsettings = import ./_floorpsettings.nix;
  extensions = import ./_extensions.nix args;
  sett = lib.recursiveUpdate settings floorpsettings;

  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "135.0";
    hash = "sha256-5fD8ffAyIgQYJ0Z/bMEpqf17YghVQNaK+giZ1Tyk6/Q=";
  };
in {
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "stylix") {
      stylix.targets.librewolf = {
        colorTheme.enable = true;
        profileNames = [ "default" ];
      };

    })

    (lib.optionalAttrs (options ? "persistence") {
      persistence.cache.directories = [ ".librewolf" ];
    })
    (lib.optionalAttrs (options.xdg.mime ? "browsers") {
      xdg.mime.browsers = [ "librewolf.desktop" ];
    })

    {
      programs.librewolf = {
        enable = true;
        profiles = {
          default = {
            id = 0;
            name = "default";
            isDefault = true;
            extraConfig = builtins.concatStringsSep "\n" [
              (builtins.readFile "${betterfox}/Securefox.js")
              (builtins.readFile "${betterfox}/Fastfox.js")
              (builtins.readFile "${betterfox}/Peskyfox.js")
            ];
            # inherit settings;
            settings = sett;
            # settings = {
            # };
            search = {
              force = true;
              engines = {
                "Options" = {
                  icon =
                    "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  # iconUpdateURL = "https://wiki.nixos.org/favicon.png";
                  # updateInterval = 24 * 60 * 60 * 1000; # every day
                  urls = [{
                    template = "https://search.xn--nschtos-n2a.de";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }];

                  definedAliases = [ "@no" ];
                  # urls = [{template = "https://wiki.nixos.org/index.php?search={searchTerms}";}];
                  # https://search.xn--nschtos-n2a.de/?query=f
                };
                "Nix Packages" = {
                  urls = [{
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }];

                  icon =
                    "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };

                "NixOS Wiki" = {
                  urls = [{
                    template =
                      "https://wiki.nixos.org/index.php?search={searchTerms}";
                  }];
                  icon =
                    "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@nw" ];
                };
              };
            };
            inherit extensions;
            # extensions = {};
          };
        };
      };
    }
  ];
}
