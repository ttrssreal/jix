# convert this to a profile once the cluster becomes multinodal

{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  services = {
    openssh.enable = true;

    # kuwubernetes
    kubernetes = {
      masterAddress = config.networking.hostName;

      addonManager.bootstrapAddons.argocd =
        let
          readYAML = pkgs.callPackage ./read-yaml.nix { };

          argo-cd = pkgs.fetchFromGitHub {
            owner = "argoproj";
            repo = "argo-cd";
            rev = "4471603de2a8f3e7e0bdfbd9d487468b6b20a354";
            hash = "sha256-NzMMzlLxGuPSCX2JiwRtWnEhS84Czm4O3a3E9jgBcU8=";
          };

          toFile = builtins.toFile "argo-bootstrap-manifest";

          argoCdNamespace = {
            apiVersion = "v1";
            kind = "Namespace";
            metadata.name = "argocd";
          };
        in
        {
          apiVersion = "v1";
          # https://kubernetes.io/docs/reference/using-api/api-concepts/#collections
          kind = "List";
          items =
            # make namespace
            (lib.singleton argoCdNamespace)

            # readYAML will only parse single documents, so split out the multi-document
            # manifest into individual documents and give them one-by-one to readYAML
            # (IFD hell...)
            ++ lib.pipe "${argo-cd}/manifests/install.yaml" [
              lib.readFile
              (lib.splitString "---")
              (map toFile)
              (map readYAML)
              (map (
                lib.recursiveUpdate {
                  metadata = {
                    namespace = argoCdNamespace.metadata.name;

                    # these aren't started by addonmanager *but* we can ask her if
                    # she'll babysit them :3
                    labels = {
                      # https://github.com/kubernetes/kubernetes/blob/5ba2b78eae/cluster/addons/addon-manager/README.md
                      "addonmanager.kubernetes.io/mode" = "EnsureExists";
                    };
                  };
                }
              ))
            ];
        };

      roles = [
        "master"
        "node"
      ];
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
}
