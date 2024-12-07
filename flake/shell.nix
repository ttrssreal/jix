{
  perSystem =
    { pkgs, inputs', ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "jix-dev-shell";
        packages = with pkgs; [
          git
          nix

          # secrets manager
          inputs'.agenix.packages.default
          rage

          inputs'.home-manager.packages.default
        ];

        NIX_CONFIG = "extra-experimental-features = nix-command flakes";
      };
    };
}
