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
    hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to enable Hyprland. Sets up a default configuration at the system and user level, and installs xdg-desktop-portal-gtk.
      '';
    };
    niri.enable = lib.mkEnableOption "Niri compositor";
    sway.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable Sway compositor. Sets up a system-level Sway installation
        with wlroots portals. Configure the rice via functorOS.desktop.sway in Home Manager.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = lib.mkIf (cfg.hyprland.enable || cfg.sway.enable) {
      enable = true;
      extraPortals =
        lib.optionals cfg.hyprland.enable [ pkgs.xdg-desktop-portal-gtk ]
        ++ lib.optionals cfg.sway.enable [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-wlr
        ];
    };

    programs.hyprland = lib.mkIf cfg.hyprland.enable {
      enable = true;
      withUWSM = true;
    };

    programs.sway = lib.mkIf cfg.sway.enable {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    services.displayManager.sessionPackages = lib.optionals cfg.hyprland.enable [
      (
        let
          desktop-file = pkgs.writeText "hyprland-functoros.desktop" ''
            [Desktop Entry]
            Name=Hyprland (functorOS)
            Comment=An intelligent dynamic tiling Wayland compositor
            Exec=${config.programs.hyprland.package}/bin/start-hyprland --no-nixgl
            Type=Application
            DesktopNames=Hyprland
            Keywords=tiling;wayland;compositor;
          '';
          uwsm-file = pkgs.writeText "hyprland-uwsm-functoros.desktop" ''
            [Desktop Entry]
            Name=functorOS Desktop
            Comment=An intelligent dynamic tiling Wayland compositor
            Exec=uwsm start -e -D Hyprland ${desktop-file}
            TryExec=uwsm
            DesktopNames=Hyprland
            Type=Application
          '';
        in
        pkgs.stdenvNoCC.mkDerivation {
          pname = "functoros-hyprland-desktop";
          version = config.programs.hyprland.package.version;

          phases = [ "installPhase" ];

          installPhase = ''
            mkdir -p $out/share/wayland-sessions
            cp ${uwsm-file} $out/share/wayland-sessions/hyprland-functoros.desktop
          '';

          passthru.providedSessions = [
            "hyprland-functoros"
          ];
        }
      )
    ];

    programs.uwsm.enable = true;

    programs.niri.enable = cfg.niri.enable;

    programs.xwayland.enable = lib.mkIf cfg.niri.enable (lib.mkForce true);

    services.xserver.enable = false;

    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
