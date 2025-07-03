{ config, lib, pkgs, modulesPath, ... }:

{

  options.lumpiasty.enablePulseaudio = lib.mkEnableOption "Enable Plasma6 desktop";

  config = lib.mkIf config.lumpiasty.enablePulseaudio {
    # Enable sound with pipewire. Dont forget after 24.05
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;

      wireplumber.configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/99-alsa-nova-3.conf" ''
          monitor.alsa.rules = [
            {
              matches = [
                {
                  node.name = "alsa_output.usb-SteelSeries_Arctis_Nova_3-00.analog-stereo"
                }
              ]
              actions = {
                update-props = {
                  audio.format = "S24LE"
                  audio.rate = 96000
                  api.alsa.period-size = 1024
                  api.alsa.period-num = 4
                  api.alsa.disable-batch = false
                }
              }
            }
          ]
        '')
      ];
    };

    # hardware.pulseaudio = {
    #   enable = true;
    #   support32Bit = true;
    #   extraConfig = ''
    #   unload-module module-role-cork
    #   '';
    # };

    # hardware.alsa.enablePersistence = true; # not implemented in 24.05

    # Remove me after 24.05
    # sound.enable = true;
  };
}