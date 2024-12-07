# https://flake.parts/overlays#consuming-an-overlay

{
  inputs,
  lib,
  ...
}:
let
  # https://github.com/NixOS/nixpkgs/blob/b11ff5d1d5dbae661a23e8c3a165adbabbfc9a27/nixos/modules/misc/nixpkgs.nix#L42
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

      config._module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (config.jix) overlays;
        config.allowUnfree = true;
      };
    };
}
