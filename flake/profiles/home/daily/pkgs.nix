{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    xgpro

    # TODO: Manage firefox profiles in nix
    # Issue URL: https://github.com/ttrssreal/jix/issues/5
    firefox

    # TODO: Manange obsidian config in nix
    # Issue URL: https://github.com/ttrssreal/jix/issues/4
    obsidian

    # TODO: Manange thunderbird config in nix
    # Issue URL: https://github.com/ttrssreal/jix/issues/3
    thunderbird

    # TODO: Generate ssh config in nix
    # Issue URL: https://github.com/ttrssreal/jix/issues/2
    openssh

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
    jetbrains.clion
    pwninit
    scripts.nix-conf-edit
    perf
    scripts.nixpkgs-print-out-paths
    binary-ninja
    resetti
    pavucontrol
  ];
}
