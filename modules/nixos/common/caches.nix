{flakeRoot, ...}: {
  imports = [
    "${flakeRoot}/caches/cachix.nix"
  ];
}
