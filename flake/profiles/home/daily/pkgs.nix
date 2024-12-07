{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    xgpro

    # TODO: Manage firefox profiles in nix
    firefox

    # TODO: Manange obsidian config in nix
    obsidian

    # TODO: Manange thunderbird config in nix
    thunderbird

    # TODO: Generate ssh config in nix
    openssh

    # TODO: Declarative barrier server in nix
    barrier

    vscode
    discord
    flameshot
    spotify
    feh
    mpv
    prismlauncher
    minikube
    qpwgraph
    ffmpeg
    cntr
    alsa-utils
    pwndbg
    patchelf
    whois
    burpsuite
    socat
    ripgrep
    libclang
    htop
    kubectl
    jq
    ghidra
    obs-studio
    gimp
    p7zip
    jetbrains.idea-ultimate
    baobab
  ];
}
