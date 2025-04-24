_:
{ inputs, pkgs, lib, config, ... }:
let
  impJ = file: builtins.fromJSON (builtins.readFile file);
  ext =
    with inputs.nur.legacyPackages."${pkgs.system}".repos.rycee.firefox-addons; [
      disable-facebook-news-feed
      playback-speed
      tridactyl
      shinigami-eyes

      darkreader
      bitwarden

      {
        package = sponsorblock;
        settings = lib.recursiveUpdate (impJ ./sponsorblock.json) { };
      }
      {
        package = ublock-origin;
        settings = impJ ./ublock-origin.json;
      }
    ];
in {
  force = true;
  settings = lib.listToAttrs (lib.filter (v: v.value != null) (map (v:
    let name = v.package.addonId or v.addonId;
    in {
      inherit name;
      value = if v ? "settings" then {
        settings = v.settings;
        force = true;
      } else
        null;
    }) ext));
  packages = map (v: if v ? "package" then v.package else v) ext;
}
