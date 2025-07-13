{config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.pc = lib.mkEnableOption "Enable options specific to personal computers";
  options.lumpiasty.gaming = lib.mkEnableOption "Enable options specific to gaming computers";
}