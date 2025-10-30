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

          fetchS3 = inputs'.buildtime-secrets-nix.packages.lib.fetchS3;

          # TODO: find a better place to put overlays that don't add new packages
          displaylink = prev.displaylink.overrideAttrs {
            # override `requireFile`
            src = final.fetchS3 {
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
