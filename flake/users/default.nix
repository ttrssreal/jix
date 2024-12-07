{
  lib,
  config,
  ...
}:
let
  cfg = config.users;
in
{
  imports = [
    ./jess.nix
  ];

  # lets us reference the defined configs for this host
  options.users.homeConfigurations = lib.mkOption {
    internal = true;
    readOnly = true;
  };

  config.modules = [
    (
      { inputs, ... }:
      {
        imports = [
          inputs.home-manager.nixosModules.default
        ];
      }
    )

    (lib.mkIf (lib.length (lib.attrsToList cfg) != 0) {
      home-manager = {
        backupFileExtension = "orig";
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    })
  ];
}
