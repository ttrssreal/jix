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
          };

          resetti = final.callPackage ./resetti.nix { };

          mc-monitor = final.callPackage ./mc-monitor.nix { };
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
          ;
      };
    };
}
