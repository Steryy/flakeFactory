{ extraInputs, ... }:
let aagl = extraInputs.aagl;
in {
  imports = [ aagl.nixosModules.default ];
  nix.settings = aagl.nixConfig; # Set up Cachix
  programs.anime-game-launcher.enable =
    true; # Adds launcher and /etc/hosts rules
  programs.anime-games-launcher.enable = true;
}
