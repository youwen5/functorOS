{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.functorOS.desktop.hyprland;
in
{
  imports = [
    ./binds.nix
    ./utilities.nix
    ./windowrules.nix
  ];

  options.functorOS.desktop.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.functorOS.desktop.enable;
      description = ''
        Whether to enable and rice Hyprland as well as some basic desktop utilities.
      '';
    };
    gtkUseOpenGL = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set GSK_RENDERER environment variable to stop GTK apps from crashing.
      '';
    };
    idleDaemon.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to setup and enable Hypridle with some defaults to automatically lock the screen and suspend after idling.
      '';
    };
    screenlocker.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable && cfg.idleDaemon.enable;
      description = ''
        Whether to set up Hyprlock for screen locking.
      '';
    };
    screenlocker.useCrashFix = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to use a workaround for Hyprlock background blur not working on some machines. Before locking, a screenshot will be taken and placed at `/tmp/__hyprlock-monitor-screenshot.png`.
      '';
    };
    screenlocker.monitor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Monitor to use for screen locker. Use `hyprctl monitors` to determine.
      '';
    };
    bluelight.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable `hyprsunset` as a daemon.
      '';
    };
    fcitx5.enable = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.i18n.inputMethod.enable && (osConfig.i18n.inputMethod.type == "fcitx5");
      description = ''
        Whether to execute fcitx5 at startup.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        wl-clipboard
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct
        papirus-icon-theme
        libsForQt5.qt5ct
        hyprland-qtutils
      ]
      ++ (lib.optionals (!osConfig.functorOS.theming.enable) [
        pkgs.bibata-cursors
      ]);

    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [ pkgs.hyprlandPlugins.hyprscroller ];
      settings = {
        exec-once = [
          "hyprctl dispatch workspace 100000"
        ]
        ++ (lib.optionals cfg.fcitx5.enable [
          "fcitx5 -d -r"
          "fcitx5-remote -r"
        ]);
        "$mod" = "SUPER";
        "$Left" = "H";
        "$Right" = "L";
        "$Up" = "K";
        "$Down" = "J";
        env = [
          # mitigates warning message due to ly workaround
          "XDG_CURRENT_DESKTOP,Hyprland"
        ]
        ++ (lib.optionals cfg.gtkUseOpenGL [
          "GSK_RENDERER,ngl"
        ])
        ++ (lib.optionals (config.functorOS.formFactor == "laptop" && !osConfig.functorOS.theming.enable) [
          "HYPRCURSOR_THEME,Bibata-Modern-Ice"
          "HYPRCURSOR_SIZE,24"
          "XCURSOR_THEME,Bibata-Modern-Ice"
          "XCURSOR_SIZE,24"
        ])
        ++ (lib.optionals (config.functorOS.formFactor == "desktop" && !osConfig.functorOS.theming.enable) [
          "HYPRCURSOR_THEME,Bibata-Modern-Ice"
          "HYPRCURSOR_SIZE,26"
          "XCURSOR_THEME,Bibata-Modern-Ice"
          "XCURSOR_SIZE,26"
        ]);
        layerrule = [
          "blur,rofi"
          "ignorezero,rofi"
          "animation slide bottom 0.2 0.2 wind,rofi"
          "blur,notifications"
          "ignorezero,notifications"
          "blur,swaync-notification-window"
          "animation slide right 0.5 0.5,swaync-control-center"
          "animation slide right 0.5 0.5,notifications"
          "animation slide right 0.5 0.5,swaync-notification-window"
          "ignorezero,swaync-notification-window"
          "blur,swaync-control-center"
          "ignorezero,swaync-control-center"
          "blur,logout_dialog"
          "blur,waybar"
          "ignorezero,waybar"
          "animation slide top 0.2 0.2 wind,waybar"
        ];
        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
        };
        animations = {
          enabled = "yes";
          bezier = [
            "wind, 0.05, 0.9, 0.1, 1.05"
            "winIn, 0.1, 1.1, 0.1, 1.1"
            "winOut, 0.3, -0.3, 0, 1"
            "liner, 1, 1, 1, 1"
            "windup, 0.05, 0.9, 0.1, 1.05"
          ];
          animation = [
            "windows, 1, 6, wind, slide"
            "windowsIn, 1, 6, winIn, slide"
            "windowsOut, 1, 5, winOut, slide"
            "windowsMove, 1, 5, wind, slide"
            "fade, 1, 10, default"
            # "layers, 1, 8, default, slide"
            "workspaces, 1, 5, wind, slidefadevert"
          ]
          ++ (lib.optionals (!osConfig.functorOS.powersave) [
            "border, 1, 1, liner"
            "borderangle, 1, 30, liner, loop"
          ]);
        };

        general =
          let
            inherit (config.lib.stylix) colors;
          in
          {
            gaps_in = "3";
            gaps_out = "8";
            border_size = "2";
            # "col.active_border" = pkgs.lib.mkForce "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            # "col.inactive_border" = pkgs.lib.mkForce "rgba(b4befecc) rgba(6c7086cc) 45deg";
            "col.active_border" = "rgba(${colors.base0A}ff) rgba(${colors.base09}ff) 45deg";
            "col.inactive_border" = "rgba(${colors.base01}cc) rgba(${colors.base02}cc) 45deg";
            layout = "scroller";
            resize_on_border = "true";
          };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        cursor = {
          hide_on_key_press = true;
        };

        decoration = {
          rounding = "10";
          dim_special = "0.3";
          blur = {
            enabled = "yes";
            size = "6";
            passes = "3";
            new_optimizations = "on";
            ignore_opacity = "on";
            xray = "false";
            special = true;
          };
          shadow = {
            enabled = false;
          };
        };
        input = {
          sensitivity = if config.functorOS.formFactor == "laptop" then "0.0" else "-0.65";
        };
        plugin.scroller = {
          column_widths = "onethird onehalf twothirds one";
          column_heights = "onethird onehalf twothirds one";
        };
        experimental.xx_color_management_v4 = true;
      };
    };

    wayland.windowManager.hyprland.settings.input.touchpad =
      lib.mkIf (config.functorOS.formFactor == "laptop")
        {
          natural_scroll = true;
          disable_while_typing = true;
          clickfinger_behavior = true;
          tap-to-click = false;
          scroll_factor = 0.15;
        };

    assertions = [
      {
        assertion =
          !cfg.screenlocker.useCrashFix || (cfg.screenlocker.useCrashFix && cfg.screenlocker.monitor != null);
        message = "To use the Nvidia crash fix, you must set screenlocker.monitor to the monitor you want to use as the lock screen that blurs! Use `hyprctl monitors` to determine the monitor codes (should be something like DP-1, HDMI-A-1, etc).";
      }
    ];
  };
}
