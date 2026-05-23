{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.functorOS.desktop;
in
{
  options.functorOS.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.functorOS.enable;
      description = ''
        Whether to enable the functorOS desktop environment.
      '';
    };
    niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to enable Niri. Sets up an opinionated configuration at the system and user level.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = cfg.niri.enable;
      useNautilus = cfg.niri.enable;
      package = pkgs.niri;
    };

    environment.systemPackages = lib.mkIf cfg.niri.enable [ pkgs.xwayland-satellite ];

    niri-flake.cache.enable = false;

    systemd.user.services.niri-flake-polkit.enable = false;

    services.xserver.enable = false;

    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
