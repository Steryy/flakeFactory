{
  pkgs,
  options,
  lib,
  config,
  ...
}: let
  forCol = file: def: replace:
    lib.concatStringsSep "\n"
    (
      lib.imap0 (i: x: ''
        substituteInPlace ${file} \
        --replace-fail '${x}' '#${lib.elemAt replace i}'
      '')
      def
    );
in {
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "stylix") {
      nixpkgs.overlays = [
        (self: super: {
          nixos-icons = super.nixos-icons.overrideAttrs (oldAttrs: {
            src = pkgs.applyPatches {
              inherit (oldAttrs) src;
              prePatch = with config.lib.stylix.colors; ''
                ${forCol "logo/nix-snowflake-white.svg" ["#ffffff"] [base04]}
                ${forCol "logo/nix-snowflake-colours.svg"
                  ["#7eb1dd" "#415e9a" "#000000"]
                  [base05 base04 base07]}
              '';
            };
          });
        })
      ];
    })
  ];
}
