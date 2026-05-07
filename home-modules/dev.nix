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
      # profiles.default.userSettings = {
      #   "claudeCode.claudeProcessWrapper" = "${pkgs.claude-code}/bin/claude-code";
      # };
    };

    # Just a fixed-location executable that launches claude code
    # so we can point vscode's extenstion at it, not the nix store path
    # remove it once we configure vscode using nix
    home.file.".config/claude-code-wrapper" = {
      text = ''
        #!${pkgs.stdenv.shell}
        exec ${pkgs.claude-code}/bin/claude "$@"
      '';
      executable = true;
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
      proton-vpn
      wl-clipboard
      devenv
      dig
      whois
      mtr
      traceroute
      nodejs_24
      codex
      claude-code
      winbox4
      amdgpu_top
      dua
    ];

    # Inject the opencode-claude-auth plugin into the user's opencode.json without
    # overwriting it — replaces any stale store path for this plugin and adds if absent.
    home.activation.opencodeClaudeAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cfg="$HOME/.config/opencode/opencode.json"
      mkdir -p "$(dirname "$cfg")"
      [ -f "$cfg" ] || echo '{}' > "$cfg"
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq --arg path "file://${pkgs.opencode-claude-auth}" '
        .plugin = ((.plugin // []) | map(select(test("opencode-claude-auth") | not)) + [$path])
      ' "$cfg" > "$tmp" && mv "$tmp" "$cfg"
    '';

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

    programs.opencode = {
      enable = true;
      package = (
        # Wrapping opencode to set the OPENCODE_ENABLE_EXA environment variable
        pkgs.runCommand "opencode" {
          buildInputs = [ pkgs.makeWrapper ];
        } ''
          mkdir -p $out/bin
          makeWrapper ${pkgs.opencode}/bin/opencode $out/bin/opencode \
            --set OPENCODE_ENABLE_EXA "1"
          ''
      );
      skills = with pkgs.skills; {
        caveman = majiayu000."claude-skill-registry".caveman + "/";
      };
    };
  };
}
