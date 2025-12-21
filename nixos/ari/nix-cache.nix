{ inputs, config, ... }:
{
  imports = [
    inputs.attic.nixosModules.atticd
  ];

  sops.secrets.attic-env-file = { };

  services.atticd = {
    enable = true;

    # jwt secret token
    # s3 key id
    # s3 secret key
    environmentFile = config.sops.secrets.attic-env-file.path;

    settings = {
      listen = "127.0.0.1:1234";
      api-endpoint = "https://ari.mudpuppy-cod.ts.net/nix-cache/";

      jwt = { };

      storage = {
        type = "s3";
        region = "us-west-002";
        bucket = "nix-cache-5d928ce4ace6";
        endpoint = "https://s3.us-west-002.backblazeb2.com";
      };

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "0";

    virtualHosts."ari.mudpuppy-cod.ts.net" = {
      locations."/nix-cache/" = {
        proxyPass = "http://127.0.0.1:1234/";
      };
    };
  };
}
