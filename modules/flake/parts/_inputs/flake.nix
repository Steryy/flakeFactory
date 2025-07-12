
{
  description = "A very basic flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs?ref=8a2f738d9d1f1d986b5a4cd2fd2061a7127237d7";
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat = {
        "owner"= "edolstra";
        "repo"= "flake-compat";
        "type"= "github";
    };
    nix-topology={url = "github:oddlama/nix-topology";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    impermanence.url = "github:nix-community/impermanence";

    nur = { url = "github:nix-community/NUR"; };
    aagl = {
      # inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ezKEa/aagl-gtk-on-nix";
    };

    matugen={url = "github:InioX/matugen";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";

      };
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";

      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
        systems.follows = "systems";
        # systems.follows = "systems";
      };
      owner = "danth";
      repo = "stylix";
      type = "github";
    };
    ags = {
      type = "github";
      owner = "Aylur";
      repo = "ags";
      rev = "237601999d65a4663bcbab934f4f6ce1f579d728";
    };
  };

  outputs = _:{};
}
