{
  jix.nixos.ari.modules = [
    (
      {
        config,
        ...
      }:
      {
        imports = [
          ./argocd
        ];

        jix.argocd = {
          targetRevision = "1704689edd5746497f29bf739eb40b661df41a67";

          sources = [
            "k8s/attic"
            "k8s/argocd-server"
            "k8s/cert-manager"
            "k8s/github-runners"
            "k8s/ingress"
            "k8s/k8s-dashboard"
            "k8s/longhorn"
            "k8s/radicale-calendar"
          ];
        };

        networking.firewall.enable = false;

        # https://github.com/longhorn/longhorn/issues/2166#issuecomment-1740179416
        systemd.tmpfiles.rules = [
          "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
        ];

        services.openiscsi = {
          enable = true;
          name = "iqn.2025-01.cafe.jessie.iscsi:ari";
        };

        # kuwubernetes
        services.kubernetes = {
          masterAddress = config.networking.hostName;
          apiserver.allowPrivileged = true;

          kubelet.cni.config = [
            # https://github.com/NixOS/nixpkgs/blob/bf21e7aff3/nixos/modules/services/cluster/kubernetes/flannel.nix#L38
            {
              name = "mynet";
              type = "flannel";
              cniVersion = "0.3.1";
              delegate = {
                isDefaultGateway = true;
                bridge = "mynet";
                hairpinMode = true; # let longhorn-manager healthcheck itself
              };
            }
          ];

          roles = [
            "master"
            "node"
          ];
        };
      }
    )
  ];

  # fix certmgr restart looping kube services
  perSystem.jix.overlays = [
    (_: prev: {
      certmgr = prev.certmgr.overrideAttrs {
        patches = [
          ./001-fix-certmgr-hostname-checks.patch
        ];
      };
    })
  ];
}
