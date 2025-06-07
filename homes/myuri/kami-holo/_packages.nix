{ pkgs,  ... }:
let
  # inherit (inputs.cells.repo.functions) getHosts;
  # hosts = getHosts inputs;
in {
  programs = {
    lazygit.enable = true;
    zsh.enable = true;
    cmus = { enable = true; };
    fd = { enable = true; };
    btop.enable = true;
    bat = { enable = true; };
    jqp = { enable = true; };
    gitui = { enable = true; };
    mangohud = { enable = true; };

  };
  home = {
    packages = with pkgs; [
      wl-clipboard-rs
      chromium
      firefox
      nautilus
      ripgrep
      ripgrep-all
      blueman
      nsxiv
      coppwr
      pwvucontrol
    ];
  };
}
