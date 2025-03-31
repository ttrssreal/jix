## Deploy

<!-- TODO: tailscale -->
Deploy to a remote machine (ex. ari the little server)
```console
nixos-rebuild switch --flake . --target-host ari --use-remote-sudo
```

Locally (will `set -x`):
`sudo nixos-sw`
`hm-sw`

## Hack

HM:
```console
home-manager switch --flake . --override-input home-manager /home/jess/.../home-manager
```

