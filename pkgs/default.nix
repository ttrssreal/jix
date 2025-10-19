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
    {
      inputs',
      pkgs,
      config,
      ...
    }:
    {
      jix.overlays = [
        (final: prev: {
          bluetooth-connect = final.callPackage ./bluetooth-connect.nix { };

          pwndbg-unwrapped = inputs'.pwndbg.packages.pwndbg;
          pwndbg = final.callPackage ./jesspwn { };

          inherit (inputs'.erosanix.lib) mkWindowsApp;
          xgpro = final.callPackage ./xgpro.nix { };

          binary-ninja = final.callPackage ./binary-ninja.nix { };

          pwninit = final.callPackage ./pwninit {
            pwninit-unwrapped = prev.pwninit;
          };

          pwntools = prev.pwntools.override {
            debugger = config.packages.pwndbg;
          };

          scripts = {
            nix-conf-edit = final.callPackage ./scripts/nix-conf-edit.nix { };
            nixpkgs-print-out-paths = final.callPackage ./scripts/nixpkgs-print-out-paths.nix { };
          };

          resetti = final.callPackage ./resetti.nix { };
        })
      ];

      packages = {
        inherit (pkgs)
          bluetooth-connect
          pwndbg
          xgpro
          binary-ninja
          pwntools
          pwninit
          resetti
          ;

        inherit (pkgs.scripts)
          nix-conf-edit
          nixpkgs-print-out-paths
          ;
      };
    };
}
