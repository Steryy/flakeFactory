{
  home = {
    shellAliases = {
      hms = "home-manager switch  -b backup --flake . && mkdir -p ~/.cache/home-manager && home-manager generations | head -n1 | awk -F' ' '{print $7}' > ~/.cache/home-manager/gen ";
      hmc = ''
        -rf ~/.local/state/nix/profiles/home-manager
        rm -rf ~/.local/state/nix/profiles/home-manager-*-link
        rm -rf ~/.local/state/nix/profiles/profile
        rm -rf ~/.local/state/nix/profiles/profile-*-link
        nix-env -p home-manager

      '';
    };
  };
}
