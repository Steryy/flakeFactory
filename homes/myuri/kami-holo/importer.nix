{
  importer = {
    inputs = {
      impermanance.enable = true;
      stylix.enable = true;
      sops-nix.enable = true;
    };
    homeProfiles = {
      zsh.enable = true;
      gpg.enable = true;
      rofi.enable = true;
      hyprland.enable = true;
      # end-4.enable = true;
      caelestia.enable = true;

      git.enable = true;
      programs = {
        ssh.enable = true;
        librewolf.enable = true;
        starship.enable = true;
        ghostty.enable = true;
        lazygit.enable = true;
        minecraft.enable = true;
        thunderbird.enable = true;
        vesktop.enable = true;
      };
    };
  };
}
