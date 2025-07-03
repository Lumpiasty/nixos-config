{ config, pkgs, ... }:

{
  home.username = "drugi";
  # home.homeDirectory = "/home/user/";

  home.packages = with pkgs; [
    spotify
    vesktop
    yubikey-personalization
    pass
    qtpass
    kubectl
    kubectx
    prismlauncher
    k9s
    kubectl
    kubernetes-helm
    xonsh
    gnumake
    python312
    python312Packages.python-lsp-server
    nil
    docker
    docker-buildx
    teamspeak_client
    easyeffects
  ];

  programs.git = {
    enable = true;
    userName = "Lumpiasty";
    userEmail = "arek.dzski@gmail.com";
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}