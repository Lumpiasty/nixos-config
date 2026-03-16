{ config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.system76Scheduler = lib.mkEnableOption "Enable system76-scheduler";

  config = lib.mkIf (config.lumpiasty.system76Scheduler) {
    # Enable system76-scheduler
    # Config basically rewrite of stock, a bit tuned
    services.system76-scheduler = {
      enable = true;
      useStockConfig = true;
    };
    # Add https://github.com/maxiberta/kwin-system76-scheduler-integration kwin script
  };
}