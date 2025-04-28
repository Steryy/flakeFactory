{
  inputs = {
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    devshell.url = "github:numtide/devshell";
    flake-root.url = "github:srid/flake-root";
  };
  outputs = _: { };
}
