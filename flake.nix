{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs = {
        nixpkgs-lib = {follows = "nixpkgs";};
      };
    };
    easy-hosts = {
      type = "github";
      owner = "tgirlcloud";
      repo = "easy-hosts";
    };
  };

  outputs = inputs @ {...}:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        inherit inputs;
      };
    } ({...}: let
    in {
      systems = ["x86_64-linux"];
      imports = [
        ./modules/flake/easy-hosts.nix
      ];
    });
}
