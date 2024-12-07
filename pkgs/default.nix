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
    { inputs', ... }:
    {
      jix.overlays = [
        (final: prev: {
          bluetooth-connect = final.callPackage ./bluetooth-connect.nix { };

          inherit (inputs'.erosanix.lib) mkWindowsApp;
          xgpro = final.callPackage ./xgpro.nix { };
        })
      ];
    };
}
