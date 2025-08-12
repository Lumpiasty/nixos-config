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
      package = pkgs.vscode.overrideAttrs rec {
        version = "1.103.0";
        src = pkgs.fetchurl {
          name = "VSCode_${version}_linux-x64.tar.gz";
          url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
          hash = "sha256-Fji3/9T8X2VQH6gUhReSuniuX2BX+4S7uPJWEZn56vc=";
        };
      };
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