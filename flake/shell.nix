{ inputs, ... }:
{
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      inputs',
      ...
    }:
    {
      pre-commit = {
        check.enable = true;
        settings.hooks = {
          treefmt.enable = true;
          nixfmt-rfc-style.enable = true;
          deadnix.enable = true;
        };
      };

      devShells.default = pkgs.mkShell {
        name = "jix-dev-shell";

        shellHook = ''
          ${config.pre-commit.installationScript}
        '';

        packages = with pkgs; [
          git
          nix

          # secrets manager
          sops
          ssh-to-age

          inputs'.home-manager.packages.default

          inputs'.colmena.packages.colmena
        ];

        NIX_CONFIG = "extra-experimental-features = nix-command flakes";
      };
    };
}
