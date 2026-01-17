{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.dev = lib.mkEnableOption "Dev account";

  config = lib.mkIf (config.lumpiastyHome.dev && osConfig.lumpiasty.pc) {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings.user = {
        name = "Lumpiasty";
        email = "arek.dzski@gmail.com";
      };
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
      direnv
      dig
      nodejs_24
      codex
      opencode
      winbox4
    ];

    # SSH config
    programs.ssh = {
      enable = true;
      # evaluation warning: user profile: `programs.ssh` default values will be removed in the future.
      # Consider setting `programs.ssh.enableDefaultConfig` to false,
      # and manually set the default values you want to keep at
      # `programs.ssh.matchBlocks."*"`.
      enableDefaultConfig = false;

      matchBlocks."*" = {
        user = "root";
        controlMaster = "auto";
        controlPersist = "3600";
        controlPath = "/run/user/%i/ssh-socket-%r@%h:%p";
        serverAliveInterval = 20;
      };

      matchBlocks."github.com".user = "git";

      extraConfig = ''
        Include config_local
      '';
    };
  };
}