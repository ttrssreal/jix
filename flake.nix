{
  description = "Nix configs for my computers :3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tsMuxer = {
      url = "github:ttrssreal/tsMuxer-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "agenix/systems";
      };
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # mkWindowsApp
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:cachix/git-hooks.nix";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake
        ./pkgs

        ./nixos/desk
        ./nixos/jess-laptop
        ./nixos/ari

        ./home/jess/desk.nix
        ./home/jess/jess-laptop.nix
        ./home/jess/ari.nix
      ];

      systems = [
        "x86_64-linux"
      ];
    };
}
