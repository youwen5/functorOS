{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.functorOS.desktop.sway;
  inherit (config.lib.stylix) colors;
in
{
  imports = [
    ./binds.nix
    ./utilities.nix
  ];

  options.functorOS.desktop.sway = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable and rice Sway as the desktop compositor.
        Uses standard sway tiling (splith/splitv).
      '';
    };
    idleDaemon.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Whether to enable swayidle for screen locking and power saving.";
    };
    screenlocker.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable && cfg.idleDaemon.enable;
      description = "Whether to enable hyprlock for screen locking.";
    };
    bluelight.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable wlsunset as a blue light filter daemon.";
    };
    fcitx5.enable = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.i18n.inputMethod.enable && (osConfig.i18n.inputMethod.type == "fcitx5");
      description = "Whether to start fcitx5 at sway startup.";
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
        hyprland-qtutils
      ]
      ++ (lib.optionals (!osConfig.functorOS.theming.enable) [
        bibata-cursors
      ]);

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export XDG_CURRENT_DESKTOP=sway
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
      ''
      + (lib.optionalString (!osConfig.functorOS.theming.enable) ''
        export XCURSOR_THEME=Bibata-Modern-Ice
        export XCURSOR_SIZE=${if config.functorOS.formFactor == "laptop" then "24" else "26"}
      '');
      config = {
        modifier = "Mod4";
        terminal = lib.getExe pkgs.kitty;
        menu = "pkill -x rofi || rofi -show drun";

        fonts = {
          names = [ config.stylix.fonts.monospace.name ];
          size = lib.mkDefault 12.0;
        };

        gaps = {
          inner = 2;
          outer = 6;
          smartBorders = "on";
        };

        window = {
          border = 2;
          titlebar = false;
          hideEdgeBorders = "smart";
          commands = [
            {
              criteria = {
                class = "kvantummanager";
              };
              command = "floating enable";
            }
            {
              criteria = {
                class = "qt5ct";
              };
              command = "floating enable";
            }
            {
              criteria = {
                class = "qt6ct";
              };
              command = "floating enable";
            }
            {
              criteria = {
                app_id = "org.pulseaudio.pavucontrol";
              };
              command = "floating enable, resize set 50% 50%";
            }
            {
              criteria = {
                title = "Picture-in-Picture";
              };
              command = "floating enable, sticky enable";
            }
            {
              criteria = {
                app_id = "nm-connection-editor";
              };
              command = "floating enable";
            }
            {
              criteria = {
                class = "nm-connection-editor";
              };
              command = "floating enable";
            }
            {
              criteria = {
                app_id = "blueman-manager";
              };
              command = "floating enable";
            }
            {
              criteria = {
                class = "vlc";
              };
              command = "floating enable";
            }
            {
              criteria = {
                app_id = "org.kde.ark";
              };
              command = "floating enable";
            }
            {
              criteria = {
                class = "eog";
              };
              command = "floating enable";
            }
            {
              criteria = {
                app_id = "app.drey.Warp";
              };
              command = "floating enable";
            }
            {
              criteria = {
                app_id = "net.davidotek.pupgui2";
              };
              command = "floating enable";
            }
            {
              criteria = {
                app_id = "yad";
              };
              command = "floating enable";
            }
          ];
        };

        floating = {
          border = 2;
          titlebar = false;
          modifier = "Mod4";
        };

        colors = lib.mkDefault {
          focused = {
            border = "#${colors.base0A}";
            background = "#${colors.base0A}";
            text = "#${colors.base00}";
            indicator = "#${colors.base09}";
            childBorder = "#${colors.base0A}";
          };
          unfocused = {
            border = "#${colors.base01}";
            background = "#${colors.base01}";
            text = "#${colors.base04}";
            indicator = "#${colors.base02}";
            childBorder = "#${colors.base01}";
          };
          focusedInactive = {
            border = "#${colors.base02}";
            background = "#${colors.base02}";
            text = "#${colors.base05}";
            indicator = "#${colors.base02}";
            childBorder = "#${colors.base02}";
          };
          urgent = {
            border = "#${colors.base08}";
            background = "#${colors.base08}";
            text = "#${colors.base00}";
            indicator = "#${colors.base08}";
            childBorder = "#${colors.base08}";
          };
        };

        # waybar manages the bar
        bars = [ ];

        focus = {
          followMouse = "yes";
          mouseWarping = "container";
          newWindow = "smart";
        };

        workspaceAutoBackAndForth = true;

        input = {
          "type:keyboard" = {
            xkb_layout = "us";
          };
          "type:pointer" = {
            accel_profile = "flat";
            pointer_accel = if config.functorOS.formFactor == "laptop" then "0.0" else "-0.65";
          };
        }
        // (lib.optionalAttrs (config.functorOS.formFactor == "laptop") {
          "type:touchpad" = {
            natural_scroll = "enabled";
            tap = "disabled";
            dwt = "enabled";
            scroll_factor = "0.15";
            click_method = "clickfinger";
          };
        });

        startup = lib.optionals cfg.fcitx5.enable [
          { command = "fcitx5 -d -r"; }
          { command = "fcitx5-remote -r"; }
        ];
      };
      extraConfig = "";
    };
  };
}
