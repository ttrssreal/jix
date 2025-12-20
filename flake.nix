{
  description = "Nix configs for my computers :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # mkWindowsApp
    erosanix.url = "github:emmanuelrosa/erosanix";
    erosanix.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: pwndbg: latest is broken, can flake input be updated yet?
    # Issue URL: https://github.com/ttrssreal/jix/issues/39
    pwndbg.url = "github:pwndbg/pwndbg/aa524de27a45a9e76f18565931db72bd33678482";
    pwndbg.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: sops-nix: remove pr patch once merged
    # Issue URL: https://github.com/ttrssreal/jix/issues/38
    # https://github.com/Mic92/sops-nix/pull/779
    sops-nix.url = "github:Mic92/sops-nix/pull/779/merge";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    buildtime-secrets-nix.url = "github:ttrssreal/buildtime-secrets-nix";
    buildtime-secrets-nix.inputs.nixpkgs.follows = "nixpkgs";

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake
        ./pkgs
        ./tests

        ./nixos/desk
        ./nixos/jess-laptop
        ./nixos/ari
        ./nixos/adair

        ./home/jess/desk
        ./home/jess/jess-laptop
        ./home/jess/ari.nix
        ./home/jess/adair.nix
      ];

      systems = [
        "x86_64-linux"
      ];
    };
}
