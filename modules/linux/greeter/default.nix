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
        Whether to enable and set up tui-greet, the default greeter for functorOS.
      '';
    };
    command = lib.mkOption {
      type = lib.types.str;
      default = if config.functorOS.desktop.enable then "Hyprland" else "";
      description = ''
        Command for the greeter to execute to launch the desktop. If the functorOS Hyprland Desktop is enabled, defaults to `Hyprland`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''
            ${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland --remember --asterisks --greeting "Welcome, generation $(readlink /nix/var/nix/profiles/system | grep -o '[0-9]*'). Access is restricted to authorized personnel only."
          '';
          user = "greeter";
        };
      };
    };

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}

