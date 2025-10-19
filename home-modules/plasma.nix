{ config, lib, pkgs, osConfig, ... }:

{
  config = lib.mkIf osConfig.lumpiasty.enablePlasma {

    home.packages = with pkgs; [
      posy-cursors
    ];

    programs.plasma = {
      enable = true;
      workspace = {
        # wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
        cursor = {
          theme = "Posy_Cursor";
          size = 32;
        };
      };
      panels = [
        {
          location = "bottom";
          screen = 0;
          floating = true;
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
              systemTray = {
                items = {
                  hidden = [ "spotify-client" ];
                  shown = [
                    "org.kde.plasma.mediacontroller"
                    "org.kde.plasma.networkmanagement"
                    "org.kde.plasma.brightness"
                    "org.kde.plasma.volume"
                    "plasmashell_microphone"
                    "org.kde.plasma.battery"
                  ];
                };
              };
            }
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.showdesktop"
          ];
        }
      ];

      input.touchpads = lib.mkIf (osConfig.lumpiasty.touchPad.enable == true) [
        osConfig.lumpiasty.touchPad
      ];

      kwin.nightLight = {
        enable = true;
        mode = "location";
        location = {
          latitude = "49.5";
          longitude = "19.5";
        };
        temperature = {
          day = null;
          night = 3500;
        };
      };

      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    };
  };
}