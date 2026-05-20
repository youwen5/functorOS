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
    programs.dms-shell = {
      enable = true;
      systemd.enable = true;
      enableDynamicTheming = false;
    };

    services.displayManager.sessionPackages = [
      (
        let
          niri-file = pkgs.writeText "functoros.desktop" ''
            [Desktop Entry]
            Name=functorOS Desktop
            Comment=Niri
            Exec=uwsm start -F -- ${config.programs.niri.package}/bin/niri-session
            TryExec=uwsm
            DesktopNames=Niri
            Type=Application
          '';
        in
        pkgs.stdenvNoCC.mkDerivation {
          pname = "functoros-desktops";
          version = config.programs.niri.package.version;

          phases = [ "installPhase" ];

          installPhase = ''
            mkdir -p $out/share/wayland-sessions
            cp ${niri-file} $out/share/wayland-sessions/functoros.desktop
          '';

          passthru.providedSessions = [
            "functoros"
          ];
        }
      )
    ];

    programs.uwsm = {
      enable = true;
      niri = lib.mkIf (config.programs ? niri) {
        prettyName = "Niri (uwsm)";
        comment = "Niri compositor managed by UWSM";
        binPath = "${config.programs.niri.package}/bin/niri-session";
      };
    };

    programs.niri = {
      enable = cfg.niri.enable;
      useNautilus = cfg.niri.enable;
      package = pkgs.niri;
    };

    environment.systemPackages = lib.mkIf cfg.niri.enable [ pkgs.xwayland-satellite ];

    niri-flake.cache.enable = false;

    services.xserver.enable = false;

    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
