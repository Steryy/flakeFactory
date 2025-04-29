{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    home-manager
    ghostty

  ];
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
