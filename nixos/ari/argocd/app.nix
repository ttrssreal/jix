# define an apps namespace + an apps project + a root app called applications
# that all other apps are deployed into as sub apps.
#
# additionally, when "bootstrapping" in the addon-manager preExec script, as
# cluster-admin, give the addon-manager permisions to deploy into the apps
# namespace, the root app.

{ lib, config, ... }:
let
  appsNamespace = {
    apiVersion = "v1";
    kind = "Namespace";
    metadata.name = "apps";
  };

  appsProject = {
    apiVersion = "argoproj.io/v1alpha1";
    kind = "AppProject";

    metadata = {
      name = "apps";
      namespace = "argocd";
    };

    spec = {
      sourceNamespaces = lib.singleton "*";
      sourceRepos = lib.singleton "*";

      destinations = lib.singleton {
        namespace = "*";
        server = "https://kubernetes.default.svc";
      };

      clusterResourceWhitelist = lib.singleton {
        group = "*";
        kind = "*";
      };
    };
  };

  createAppsRole = {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "ClusterRole";

    metadata = {
      name = "apps-create";
    };

    rules = lib.singleton {
      apiGroups = lib.singleton "argoproj.io";
      resources = lib.singleton "applications";
      verbs = lib.singleton "*";
    };
  };

  giveCreateAppsRole = subject: {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "RoleBinding";

    metadata = {
      name = "${createAppsRole.metadata.name}-binding";
      namespace = appsNamespace.metadata.name;
    };

    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      inherit (createAppsRole) kind;
      inherit (createAppsRole.metadata) name;
    };

    subjects = lib.singleton subject;
  };
in
{
  options.jix.argocd.targetRevision = lib.mkOption {
    type = lib.types.str;
  };

  config.services.kubernetes.addonManager = {
    bootstrapAddons = {
      inherit appsNamespace appsProject createAppsRole;

      addonManagerRoleBinding = giveCreateAppsRole {
        apiGroup = "rbac.authorization.k8s.io";
        kind = "User";
        name = "system:kube-addon-manager";
      };
    };

    addons = {
      applications = {
        apiVersion = "argoproj.io/v1alpha1";
        kind = "Application";
        metadata = {
          name = "applications";
          namespace = appsNamespace.metadata.name;
          finalizers = lib.singleton "resources-finalizer.argocd.argoproj.io";
          labels."addonmanager.kubernetes.io/mode" = "Reconcile";
        };

        spec = {
          project = appsProject.metadata.name;

          source = {
            inherit (config.jix.argocd) targetRevision;
            repoURL = "https://github.com/ttrssreal/jix";
            path = "k8s";
          };

          destination = {
            server = "https://kubernetes.default.svc";
            namespace = appsNamespace.metadata.name;
          };

          syncPolicy = {
            automated = {
              prune = true;
              selfHeal = true;
              allowEmpty = false;
            };

            syncOptions = lib.mapAttrsToList (n: v: "${n}=${v}") {
              PruneLast = "true";
              PrunePropagationPolicy = "foreground";
            };

            retry = {
              limit = -1;
              backoff = {
                duration = "5s";
                factor = 2;
                maxDuration = "3m";
              };
            };
          };

          revisionHistoryLimit = 10;
        };
      };
    };
  };
}
