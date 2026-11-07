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
    niri.performative = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable expressive Niri animations and window and panel styling.
      '';
    };
    horosphere.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable Horosphere, the optional Cage-backed Horosphere desktop session;
        see <https://x.com/undebeha/status/2115974794751701503> for more info
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = cfg.niri.enable;
      useNautilus = cfg.niri.enable;
      package = pkgs.niri;
    };

    programs.horosphere = {
      enable = cfg.horosphere.enable;
      sessionEnvironment = {
        HOROSPHERE_TERMINAL = "${pkgs.kitty}/bin/kitty";
      };
    };

    services.displayManager.defaultSession = lib.mkIf cfg.niri.enable (lib.mkDefault "niri");

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
