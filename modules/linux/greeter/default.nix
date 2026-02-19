{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.functorOS.desktop.greeter;
in
{
  options.functorOS.desktop.greeter = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.functorOS.desktop.enable;
      description = ''
        Whether to enable and set up ly, the default greeter for functorOS.
      '';
    };
    command = lib.mkOption {
      type = lib.types.str;
      # must pass --no-nixgl as NixOS check fails since we are on functorOS
      default = if config.functorOS.desktop.enable then "start-hyprland --no-nixgl" else "";
      description = ''
        Command for the greeter to execute to launch the desktop. If the functorOS Hyprland Desktop is enabled, defaults to `start-hyprland`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # from https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988
    systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";
    services.displayManager.ly = {
      enable = true;
      x11Support = false;
      settings = {
        animation = "colormix";
        vi_mode = false;
        colormix_col1 = "0x00${config.lib.stylix.colors.base00}";
        colormix_col2 = "0x00${config.lib.stylix.colors.base07}";
        colormix_col3 = "0x00${config.lib.stylix.colors.base0F}";
      };
    };
  };
}
