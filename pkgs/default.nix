{
  inputs,
  ...
}:
{
  perSystem =
    {
      inputs',
      pkgs,
      config,
      system,
      ...
    }:
    {
      jix.overlays = [
        (final: prev: {
          bluetooth-connect = final.callPackage ./bluetooth-connect.nix { };

          pwndbg-unwrapped = inputs'.pwndbg.packages.pwndbg;
          pwndbg = final.callPackage ./jesspwn { };

          inherit (inputs.erosanix.lib.${system}) mkWindowsApp;
          xgpro = final.callPackage ./xgpro.nix { };

          binary-ninja = final.callPackage ./binary-ninja.nix { };

          pwninit = final.callPackage ./pwninit {
            pwninit-unwrapped = prev.pwninit;
          };

          pwntools = prev.pwntools.override {
            debugger = config.packages.pwndbg;
          };

          jess-scripts = {
            nix-conf-edit = final.callPackage ./scripts/nix-conf-edit.nix { };
            nixpkgs-print-out-paths = final.callPackage ./scripts/nixpkgs-print-out-paths.nix { };
            edit-managed-file = final.callPackage ./scripts/edit-managed-file.nix { };
          };

          resetti = final.callPackage ./resetti.nix { };

          mc-monitor = final.callPackage ./mc-monitor.nix { };

          # Use the development release (has the Akahu provider)
          firefly-iii-data-importer = prev.firefly-iii-data-importer.overrideAttrs (prevAttrs: rec {
            src = final.fetchFromGitHub {
              owner = "firefly-iii";
              repo = "data-importer";
              tag = "develop-20260901";
              hash = "sha256-i9pQBGGpIfXc+fd+t5cfcVcv4ZrWsZa/uMK065xmpvI=";
            };

            vendorHash = "sha256-7Cr9u9+BImRTh6l6srT7BldDvQCBwtQuCHEHrYn7aCQ=";

            npmDeps = final.fetchNpmDeps {
              inherit src;
              name = "${prevAttrs.pname}-npm-deps";
              hash = "sha256-UKEm+4DNbQbWpDVg65BTdyGeisC/EFyJNcbxkqiLOrs=";
            };
          });
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
          mc-monitor
          ;

        inherit (pkgs.jess-scripts)
          nix-conf-edit
          nixpkgs-print-out-paths
          edit-managed-file
          ;
      };
    };
}
