{
  pkgs,
  inputs,
  ...
}: let
  # inherit (inputs.cells.repo.functions) getHosts;
  # hosts = getHosts inputs;
in {
  programs = {
    lazygit.enable = true;
    zsh.enable = true;
    cmus = {
      enable = true;
    };
    fd = {
      enable = true;
    };
    btop.enable =
      true;
    bat = {
      enable = true;
    };
    jqp = {
      enable = true;
    };
    gitui = {
      enable = true;
    };
    mangohud = {
      enable = true;
    };

    ssh = {
      enable = true;
      # matchBlocks =
      #   hosts;
    };
  };
  xdg.mime.fileManagers = [
    "Nautilus.desktop"
    "Dolphin.desktop"
  ];
  home = {
    packages = with pkgs; [
      chromium
      firefox
      dolphin
      nautilus
      ripgrep
      ripgrep-all
      blueman
      nsxiv
      # nexusmods-app-unfree
      # (nexusmods-app.override {
      #   _7zz = _7zz-rar;
      # })
      # nexusmods-app

      coppwr
      pwvucontrol

      waybar
      inputs.nur.legacyPackages."${pkgs.system}".repos.zzzsy.zen-browser
      inputs.nixpkgs-stable.legacyPackages."${pkgs.system}".bitwarden-cli
    ];
  };
}
