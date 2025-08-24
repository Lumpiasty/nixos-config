{ config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.acerUndervolt = lib.mkEnableOption "Enable Acer undervolt module";

  config = lib.mkIf config.lumpiasty.acerUndervolt (
  let 
    # Use forked version of ryzen_smu
    # https://github.com/FlyGoat/RyzenAdj/issues/350#issuecomment-2971428510
    ryzen-smu = config.boot.kernelPackages.ryzen-smu.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "amkillam";
        repo = "ryzen_smu";
        rev = "172c316f53ac8f066afd7cb9e1da517084273368";
        sha256 = "sha256-U2UMWY7XgLXOpNgl2OsFBRvZSC4/qLa9rzJxFOpZ830=";
      };
    });
    ryzenadj = pkgs.ryzenadj.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "FlyGoat";
        repo = "RyzenAdj";
        rev = "7aeb2f4869ee52ac161ee4cb4871e29113487885";
        sha256 = "sha256-KE2dbGv4V3+ibyxJ/DHNnBOGzjAcZbGrC3cVGNDsTTQ=";
      };
    });
  in {
    # Undervolting
    boot.kernelModules = [ "ryzen-smu" ];

    boot.extraModulePackages = [
      ryzen-smu
    ];

    environment.systemPackages = [
      ryzenadj
      ryzen-smu
    ];

    programs.corectrl.enable = true;
    hardware.amdgpu.overdrive.enable = true;
  });
}