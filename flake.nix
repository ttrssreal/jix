{
  description = "Nix configs for my computers :3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    stable.url = "github:NixOS/nixpkgs?ref=nixos-24.05";
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

        ./home/jess-at-desk
        ./home/jess-at-jess-laptop
        ./home/jess-at-ari
      ];

      systems = [
        "x86_64-linux"
      ];
    };
}
