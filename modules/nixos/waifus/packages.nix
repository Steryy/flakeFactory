{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    home-manager
    ghostty

  ];
}
