{
  lib,
  config,
  inputs,
  withSystem,
  ...
}:
let
  deployable = lib.filterAttrs (_: host: host.deployment.enable) config.jix.nixos;
  mapDeployable = f: lib.mapAttrs f deployable;
in
{
  flake.colmenaHive = inputs.colmena.lib.makeHive (
    {
      meta = {
        nixpkgs = {
          lib = inputs.nixpkgs.lib;
          path = "${inputs.nixpkgs}";
        };

        nodeNixpkgs = mapDeployable (_: host: withSystem host.system (lib.getAttr "pkgs"));
        nodeSpecialArgs = mapDeployable (_: lib.getAttr "specialArgs");
      };
    }
    // (lib.mapAttrs (_: host: {
      imports = host.modules;
      deployment = host.deployment.cfg;
    }) deployable)
  );
}
