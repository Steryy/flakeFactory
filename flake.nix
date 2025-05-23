{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs = { nixpkgs-lib = { follows = "nixpkgs"; }; };
    };

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
treefmt-nix.follows = "treefmt-nix";
      };
    };
    sops-nix.follows = "clan-core/sops-nix";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    haumea = {
      inputs = { nixpkgs = { follows = "nixpkgs"; }; };
      owner = "nix-community";
      repo = "haumea";
      type = "github";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      owner = "nix-community";
      repo = "disko";
      type = "github";
    };

    terranix = {
      url = "github:Enzime/terranix/terranix-plus";
      inputs = {
        bats-assert.follows = "";
        bats-support.follows = "";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        terranix-examples.follows = "";
      };
    };
  };

  outputs = inputs @ {...}: let
    lib = inputs.nixpkgs.lib;
    haumea = inputs.haumea.lib;

    flakeModules =
      lib.collect (x: lib.isPath x)
      (
        haumea.load {
          src = ./modules/flake;
          loader = haumea.loaders.path;
        }
      );
  in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        inherit inputs;
        flakeRoot = ./.;
      };
    } ({...}: {
      systems = ["x86_64-linux"];
      haumea = {
        nixModules = {
          src = ./modules/nixos;
      };
        hosts = {
          src = ./hosts;
          loader = _: import;
          _pipe = [
            (lib.attrsets.mapAttrsRecursiveCond (x: !(x ? "default"))
              (_: v: if v ? "default" then v.default else v))
            (lib.mapAttrs (n:
              lib.filterAttrs (n2: v:
                if v ? "modules" then
                  true
                else
                  throw "Host ${n}-${n2} doesnt have modules")))
            (lib.mapAttrs (n:
              lib.mapAttrs' (n2: value: {
                inherit value;
                name = "${n}-${n2}";
              })))
          ];
        };
        homeModules = {
          src = ./modules/home;
          _pipe = [
            (lib.attrsets.mapAttrsRecursiveCond (x: !(x ? "default"))
              (_: v: if v ? "default" then v.default else v))
          ];
        };
        diskoModules = {
          src = ./modules/disko;
        };
        clanServices = { src = ./modules/clan; };
      };
      imports =
        flakeModules;
    });
}
