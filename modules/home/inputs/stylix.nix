{
  config,
  inputs,
  pkgs,
  lib,
  extraInputs,
  ...
}: let
in {
  imports = [
    extraInputs.stylix.homeManagerModules.stylix
  ];

  home.pointerCursor = lib.mkForce {
    inherit (config.stylix.cursor) name package size;
    hyprcursor.enable = true;
    x11.enable = true;
    gtk.enable = true;
  };
  stylix.autoEnable = lib.mkForce true;

  stylix.fonts = {
    sizes = {
      terminal = 11;
    };
  };

  stylix.iconTheme = {
    enable = true;
    package = pkgs.rose-pine-icon-theme;
    dark = "rose-pine-moon";
    light = "rose-pine-dawn";
  };
  stylix.opacity.terminal = lib.mkForce 0.95;

  programs.wezterm.enable = true;
  programs.foot.enable = true;
  programs.kitty.enable = true;
  # programs.foot.settings = { main = «thunk»; scrollback = «thunk»; };
}
