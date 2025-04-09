{ flakeRoot, ... }: {
  imports = [
    ({ config, pkgs,
      # lib,
      ... }: {
        services.blueman-applet.enable = true;
        home.packages = with pkgs; [
          neovim
          librewolf-wayland
          noto-fonts
          notonoto
          noto-fonts-emoji-blob-bin
        ];
        fonts.fontconfig.enable = true;
        programs.helix.enable = true;
      })
  ];
}
