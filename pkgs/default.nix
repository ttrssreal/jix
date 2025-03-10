{
  # mkWindowsApp from erosanix uses a system parameterized lib?
  # would be nice to do:
  #   `transposition.lib.noOutput = true;`
  # TODO: flake-parts: input only transpositions?
  # Issue URL: https://github.com/ttrssreal/jix/issues/6
  perInput = system: flake: {
    lib = flake.lib.${system};
  };

  perSystem =
    { inputs', pkgs, ... }:
    {
      jix.overlays = [
        (final: _: {
          bluetooth-connect = final.callPackage ./bluetooth-connect.nix { };
          tsMuxer = final.callPackage ./ts-muxer.nix { };
          particle-cli = final.callPackage ./particle-cli.nix { };

          pwndbg-unwrapped = inputs'.pwndbg.packages.pwndbg;
          pwndbg = final.callPackage ./pwndbg.nix { };

          inherit (inputs'.erosanix.lib) mkWindowsApp;
          xgpro = final.callPackage ./xgpro.nix { };
        })
      ];

      packages = {
        inherit (pkgs)
          bluetooth-connect
          tsMuxer
          particle-cli
          pwndbg
          xgpro
          ;
      };
    };
}
