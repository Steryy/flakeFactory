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

    haumea = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      owner = "nix-community";
      repo = "haumea";
      type = "github";
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
    } ({...}: {
      systems = ["x86_64-linux"];
      haumea = {
        nixModules = {
          src = ./modules/nixos;
        };
      };
      imports = [
        ./modules/flake/easy-hosts.nix

        ./modules/flake/haumea.nix
      ];
    });
}
