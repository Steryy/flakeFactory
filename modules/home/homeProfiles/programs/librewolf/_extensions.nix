_:
{ inputs, pkgs, lib, config, ... }:
let
  impJ = file: builtins.fromJSON (builtins.readFile file);
  ext =
    with inputs.nur.legacyPackages."${pkgs.system}".repos.rycee.firefox-addons; [
      tridactyl
      shinigami-eyes

      darkreader
      bitwarden
      buster-captcha-solver
      british-english-dictionary-2
      polish-dictionary
      privacy-badger
      return-youtube-dislikes
      multi-account-containers
      istilldontcareaboutcookies

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
