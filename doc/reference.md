## Deploy

Deploy to a remote machine:
```console
colmena apply --on <name>
```

Local is `sudo nixos-sw`, and `hm-sw` for home manager.

## Secrets

With PGP key in local keyring run `sops edit secrets/nixos.yaml` to edit nixos secrets.

## Tests

Run `nix build -L .#test-<name>` to execute a test, and
`nix build -L .#test-<name>.driverInteractive` to debug tests.

## Hacking

home-manager: `home-manager switch --flake . --override-input home-manager <hm-path>`

## Wireguard

Start and stop the `wireguard-wg0.service` unit
