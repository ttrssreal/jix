## Deploy

<!-- TODO: tailscale -->
Deploy to a remote machine (ex. ari the little server)
```console
colmena apply --on ari
```

Locally (will `set -x`):
`sudo nixos-sw`
`hm-sw`

## Secrets

With pgp key in local keyring run `sops edit secrets/nixos.yaml` to edit nixos secrets.

## Tests

Run `nix build -L .#test-<name>` to execute a test, and
`nix build -L .#test-<name>.driverInteractive` to debug tests.

## Hack

HM:
```console
home-manager switch --flake . --override-input home-manager /home/jess/.../home-manager
```

