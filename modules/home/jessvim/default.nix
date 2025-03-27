{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.jix.jessvim;
in
{
  imports = [
    inputs.nixvim.homeManagerModules.default

    ./plugins.nix
    ./keymaps.nix
    ./options.nix
  ];

  options.jix.jessvim.enable = lib.mkEnableOption "jessvim";

  config.programs.nixvim = lib.mkIf cfg.enable {
    enable = true;
    defaultEditor = true;
    colorschemes.tokyonight.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    filetype.extension.sage = "python";
  };
}
