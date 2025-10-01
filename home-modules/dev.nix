{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.dev = lib.mkEnableOption "Dev account";

  config = lib.mkIf (config.lumpiastyHome.dev && osConfig.lumpiasty.pc) {
    programs.git = {
      enable = true;
      lfs.enable = true;
      userName = "Lumpiasty";
      userEmail = "arek.dzski@gmail.com";
    };

    programs.vscode = {
      enable = true;
      profiles.default.extensions = [
        pkgs.vscode-extensions.github.copilot
        pkgs.vscode-extensions.github.copilot-chat
        pkgs.vscode-extensions.arrterian.nix-env-selector
        pkgs.vscode-extensions.jnoortheen.nix-ide
      ];
    };

    home.packages = with pkgs; [
      python312
      python312Packages.python-lsp-server
      nil
      kubectl
      kubectx
      k9s
      kubectl
      kubernetes-helm
      xonsh
      gnumake
      docker
      docker-buildx
      protonvpn-gui
      wl-clipboard
      devenv
      dig
      nodejs_24
      codex
    ];

    # SSH config
    home.file.sshconfig = {
      enable = true;
      executable = false;
      source = ssh/config;
      target = ".ssh/config";
    };
  };
}