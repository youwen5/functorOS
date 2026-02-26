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
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = lib.mkIf cfg.hyprland.enable {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    programs.hyprland = lib.mkIf cfg.hyprland.enable {
      enable = true;
      withUWSM = true;
    };

    environment.systemPackages = [
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
            Exec=uwsm start -e -D Hyprland hyprland-functoros.desktop
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
            cp ${desktop-file} $out/share/wayland-sessions/hyprland-functoros.desktop
            cp ${uwsm-file} $out/share/wayland-sessions/hyprland-uwsm-functoros.desktop
          '';

          passthru.providedSessions = [
            "hyprland-functoros"
            "hyprland-uwsm-functoros.desktop"
          ];
        }
      )
    ];

    # nixpkgs.overlays = [
    #   (final: prev: {
    #     hyprland = prev.hyprland.overrideAttrs (
    #       finalAttrs: prevAttrs: {
    #         nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ prev.makeWrapper ];
    #         postInstall = prevAttrs.postInstall + ''
    #           wrapProgram $out/bin/start-hyprland \
    #             --add-flags "--no-nixgl"
    #         '';
    #       }
    #     );
    #   })
    # ];

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
