# https://flake.parts/overlays#consuming-an-overlay

{
  inputs,
  lib,
  ...
}:
let
  # https://github.com/NixOS/nixpkgs/blob/b11ff5d1d5/nixos/modules/misc/nixpkgs.nix#L42
  overlayType = lib.mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };
in
{
  config.perSystem =
    { system, config, ... }:
    {
      options.jix.overlays = lib.mkOption {
        type = lib.types.listOf overlayType;
        default = [ ];
      };

      config = {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          inherit (config.jix) overlays;
          config.allowUnfree = true;
        };

        jix.overlays = [
          inputs.buildtime-secrets-nix.overlays.default

          (final: prev: {
            displaylink = prev.displaylink.overrideAttrs {
              # override `requireFile`
              src = final.fetchs3 {
                name = "displaylink-620.zip";
                s3Path = "nix-private-66670f8190bb/displaylink-620.zip";
                s3Endpoint = "https://s3.us-west-002.backblazeb2.com";
                credentialsSecret = {
                  name = "displaylink-driver-src-credentials";
                  hash = "meow";
                };
                hash = "sha256-JQO7eEz4pdoPkhcn9tIuy5R4KyfsCniuw6eXw/rLaYE=";
              };
            };
          })
        ];
      };
    };
}
