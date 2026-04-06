{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  xdg.configFile."waywall/init.lua".source = pkgs.replaceVars ./waywall.lua {
    ninjabrain-bot =
      lib.getExe' inputs.mcsr-nixos.packages.${pkgs.stdenv.hostPlatform.system}.ninjabrain-bot
        "ninjabrain-bot";
  };
}
