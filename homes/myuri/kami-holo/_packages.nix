{ pkgs, osConfig, lib, ... }:
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

    ssh = {
      enable = true;
      matchBlocks = lib.mapAttrs' (_: v:
        let splited = lib.strings.splitString "@" v.deploy.targetHost;
        in {
          name = v.name;
          value = {
            user = lib.elemAt splited 0;
            hostname = lib.elemAt splited 1;
          };
        }) osConfig.clan.inventory.machines;
      # matchBlocks =
      #   hosts;
    };
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
