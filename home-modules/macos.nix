{ config, lib, pkgs, osConfig, ... }:

let
  brewPath = config.homebrew.brewPath;
in {
  config = lib.mkIf config.lumpiastyHome.macos {
    targets.darwin.copyApps.enable = true;
    targets.darwin.linkApps.enable = false;

    homebrew = {
      enable = true;
      brewInstall = true;
      update = true;
      upgrade = true;
      cleanup = true;
      casks = [
        "steam"
      ];
    };

    home.activation.homebrewInstall = lib.mkForce (
      lib.hm.dag.entryAfter ["installPackages" "linkGeneration" "createGpgHomedir"] (
        if config.homebrew.brewInstall then ''
          if [ ! -f "${brewPath}" ]; then
            echo "Homebrew not found (${brewPath}), installing..."
            export PATH="${pkgs.curl}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:$PATH"
            ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi
        '' else ""
      )
    );
  };
}
