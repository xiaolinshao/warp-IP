{ pkgs }: {
    deps = [
        pkgs.wireguard-tools
        pkgs.wget
        pkgs.qrencode.bin
        pkgs.busybox
        pkgs.bashInteractive
        pkgs.man
    ];
}