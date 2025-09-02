{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.functorOS.system.asahi;
in
{
  options.functorOS.system.asahi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to use Asahi Linux kernel for nix
      '';
    };
    firmware = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        path to directory of the firmware
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    imports = [
      "${inputs.apple-silicon}/apple-silicon-support"
    ];
    networking.wireless.iwd.enable = true;
    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = false;
      kernelParams = [ "apple_dcp.show_notch=1" ];
      extraModprobeConfig = ''
        options hid_apple iso_layout=0
      '';
    };
    hardware.asahi = {
      enable = true;
      peripheralFirmwareDirectory = cfg.firmware;
    };
    nixpkgs.overlays = [
      inputs.apple-silicon.overlays.apple-silicon-overlay
    ];
    services.udev.extraRules = ''
      KERNEL=="macsmc-battery", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}="90", ATTR{charge_control_start_threshold}="85"
    '';

  };
}
