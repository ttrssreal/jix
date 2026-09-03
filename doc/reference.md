## Deploy

Deploy to a remote machine:
```console
colmena apply --on <name>
```

Local is `sudo nixos-sw`, and `hm-sw` for home manager.

## Secrets

Buildtime and activationtime secrets. To add a new buildtime secret: `sops edit secrets/buildtime.yaml`,
enable the module and put this in the derivation,
```
requiredSystemFeatures = [ "buildtime-secrets" ];
buildtimeSecrets = [ credentialsSecret ];
```

NixOS secrets in `secrets/nixos.yaml` are decrypted at activation-time.

With PGP key in local keyring run `sops edit secrets/nixos.yaml` to edit nixos secrets.

## Tests

Run `nix build -L .#test-<name>` to execute a test, and
`nix build -L .#test-<name>.driverInteractive` to debug tests.

## Hacking

home-manager: `home-manager switch --flake . --override-input home-manager <hm-path>`

## Renew certificates
 - Get new certs: `sudo tailscale cert ari.mudpuppy-cod.ts.net`
 - `certbot certonly -n --agree-tos --logs-dir certs/logs --config-dir certs/config --work-dir certs/work --dns-cloudflare --dns-cloudflare-credentials cf-creds -d '*.app.jessie.cafe'`
 - Set wildcard cert key `sops set secrets/nixos.yaml '["wildcard-app-cert-key"]' "$(cat certs/config/live/app.jessie.cafe/privkey.pem | jq -Rsa)"`
 - Set wildcard cert `sops set secrets/nixos.yaml '["wildcard-app-cert"]' "$(cat certs/config/live/app.jessie.cafe/fullchain.pem | jq -Rsa)"`

## Wireguard

Start and stop the `wireguard-wg0.service` unit

## Cache

To use the cache when building flake outputs add the following `nixConfig` to `flake.nix`:
```nix
    description = ...;

    nixConfig = {
      extra-substituters = [
        "https://nix-cache.app.jessie.cafe"
      ];

      trusted-public-keys = [
        "main:CQvMVlbvoG+oXkC+d4ODlylKKh06rt0qPQlc0XQ3L5g="
      ];

      netrc-file = "<cache-creds-file>";
    };

    inputs = {
        ...
```
