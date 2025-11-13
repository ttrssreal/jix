{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.jix.aflplusplus;
in
{
  options.jix.aflplusplus = lib.mkOption {
    type =
      with lib.types;
      attrsOf (submodule {
        options = {
          enable = lib.mkEnableOption "this fuzzer";
          main = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          target = lib.mkOption {
            type = lib.types.str;
          };
          extraArgs = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ ];
          };
          extraEnvs = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ ];
          };
          corpusDir = lib.mkOption {
            type = lib.types.str;
          };
          outDir = lib.mkOption {
            type = lib.types.str;
          };
        };
      });
    default = { };
  };

  config.systemd.services = lib.mkMerge (
    lib.mapAttrsToList (name: fuzzer: {
      "aflplusplus-${name}" = lib.mkIf fuzzer.enable {
        description = "Aflplusplus fuzzing instance";

        serviceConfig = {
          ExecStart = lib.concatStringsSep " " (
            lib.flatten [
              "${lib.getExe' pkgs.aflplusplus "afl-fuzz"}"
              "-i"
              fuzzer.corpusDir
              "-o"
              fuzzer.outDir
              "-${if fuzzer.main then "M" else "S"}"
              name
              fuzzer.extraArgs
              "--"
              "${fuzzer.target}"
            ]
          );

          Environment = (
            lib.flatten [
              "AFL_NO_UI=1"
              "AFL_STATSD_TAGS_FLAVOR=dogstatsd"
              "AFL_STATSD=1"
              "AFL_STATSD_PORT=9125"
              "AFL_TESTCACHE_SIZE=500"
              fuzzer.extraEnvs
            ]
          );
        };
      };
    }) cfg
  );
}
