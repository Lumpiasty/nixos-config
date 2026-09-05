{ config, lib, pkgs, ... }:

let
  brewPath = config.homebrew.brewPath;
in {
  options.lumpiastyHome.brew = lib.mkEnableOption "Homebrew integration via home-manager-brew";

  config = lib.mkMerge [
    (lib.mkIf config.lumpiastyHome.brew {
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
    })
    (lib.mkIf (!config.lumpiastyHome.brew) {
      homebrew.enable = lib.mkForce false;
    })
  ];
}
