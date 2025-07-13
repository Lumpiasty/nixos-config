{ config, lib, pkgs, osConfig, ... }:

{
  config = lib.mkIf osConfig.lumpiasty.enablePlasma {
    programs.plasma = {
      enable = true;
      workspace = {
        # wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";

      };
      panels = [
        {
          location = "bottom";
          # screen is broken, outputs some panel.writeConfig("lastScreen[$i]", 0) nonsense
          # https://github.com/nix-community/plasma-manager/blob/b7697abe89967839b273a863a3805345ea54ab56/lib/panel.nix#L38
          # screen = 0;
          # JS code to be added at the end of activation script
          extraSettings = ''
            panel.screen = 0;
          '';
          widgets = [
            {
              kickoff = {
                sortAlphabetically = true;
                icon = "nix-snowflake-white";
              };
            }
            "org.kde.plasma.pager"
            "org.kde.plasma.taskmanager"
            "org.kde.plasma.marginsseparator"
            {
              # systemTray module is broken
              # https://github.com/nix-community/plasma-manager/blame/b7697abe89967839b273a863a3805345ea54ab56/modules/widgets/system-tray.nix#L223
              # SystrayContainmentId appears to be null so no settings are applied
              name = "org.kde.plasma.systemtray";
              config = {
                General = {
                  hiddenItems = [ "spotify-client" ];
                  shownItems = [
                    "org.kde.plasma.mediacontroller"
                    "org.kde.plasma.networkmanagement"
                    "org.kde.plasma.brightness"
                    "org.kde.plasma.volume"
                    "plasmashell_microphone"
                  ];
                };
              };
            }
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.showdesktop"
          ];
        }
      ];
    };
  };
}