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
      dig
      whois
      mtr
      nodejs_24
      codex
      claude-code
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

    programs.direnv.enable = true;

    # Replace the default bash integration with our own
    # which can be disabled with the DISABLE_DIRENV environment variable
    # useful for VSCode's integrated terminal with direnv extension
    # so we don't apply the direnv hook twice
    # TODO: configure vscode to set DISABLE_DIRENV in the integrated terminal
    programs.direnv.enableBashIntegration = false;
    programs.bash.initExtra = (
      # Using `mkAfter` to make it more likely to appear after other
      # manipulations of the prompt.
      lib.mkAfter ''
        if [ -z "$DISABLE_DIRENV" ]; then
          eval "$(${lib.getExe config.programs.direnv.package} hook bash)"
        fi
      ''
    );
  };
}