{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.functorOS.system.ramRgb;
  openrgb = "${pkgs.openrgb}/bin/openrgb --noautoconnect --device ${lib.escapeShellArg cfg.device}";
in
{
  options.functorOS.system.ramRgb = {
    enable = lib.mkEnableOption "RAM lighting off during sleep and on after resume";
    device = lib.mkOption {
      type = lib.types.str;
      default = "Corsair Vengeance RGB DDR5";
      description = "OpenRGB device name matching the RAM sticks to control.";
    };
    resumeMode = lib.mkOption {
      type = lib.types.str;
      default = "Rainbow Wave";
      description = "OpenRGB lighting mode to apply after resume.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "i2c-dev" ];
    environment.systemPackages = [ pkgs.openrgb ];
    services.udev.packages = [ pkgs.openrgb ];

    systemd.services.ram-rgb-sleep = {
      description = "Turn RAM lighting off for sleep and on after resume";
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      unitConfig.StopWhenUnneeded = true;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "ram-rgb";
        Environment = "HOME=/var/lib/ram-rgb";
        TimeoutStartSec = "20s";
        TimeoutStopSec = "20s";
      };
      script = ''
        ${openrgb} --mode Direct --color 000000
      '';
      preStop = ''
        ${openrgb} --mode ${lib.escapeShellArg cfg.resumeMode}
      '';
    };
  };
}
