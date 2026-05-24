{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.functorOS.desktop.niri;
in
{
  options.functorOS.desktop.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.functorOS.desktop.niri.enable;
      description = ''
        Whether to enable and rice Niri.
      '';
    };
    reduceMotion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to remove overshoots from window animations and speed them up.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages =
          (with pkgs; [
            wl-clipboard
            libsForQt5.qtstyleplugin-kvantum
            libsForQt5.qt5ct
            papirus-icon-theme
            libsForQt5.qt5ct
          ])
          ++ (lib.optionals (!osConfig.functorOS.theming.enable) [
            pkgs.bibata-cursors
          ]);

        programs.rofi = {
          enable = true;
          terminal = "${lib.getExe pkgs.kitty}";
          theme =
            let
              inherit (config.lib.formats.rasi) mkLiteral;
              mkRgba =
                opacity: color:
                let
                  c = config.lib.stylix.colors;
                  r = c."${color}-rgb-r";
                  g = c."${color}-rgb-g";
                  b = c."${color}-rgb-b";
                in
                mkLiteral "rgba ( ${r}, ${g}, ${b}, ${opacity} % )";
              mkRgb = mkRgba "100";
              rofiOpacity = builtins.toString (builtins.ceil (config.stylix.opacity.popups * 100));
            in
            {
              "*" = {
                font = "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.popups}";
                text-color = mkRgb "base05";
                background-color = mkRgba rofiOpacity "base00";
              };
              "window" = {
                height = mkLiteral "20em";
                width = mkLiteral "30em";
                border-radius = mkLiteral "8px";
                border-width = mkLiteral "2px";
                padding = mkLiteral "1.5em";
              };
              "mainbox" = {
                background-color = mkRgba rofiOpacity "base01";
              };
              "inputbar" = {
                margin = mkLiteral "0 0 1em 0";
              };
              "prompt" = {
                enabled = false;
              };
              "entry" = {
                placeholder = "Search...";
                padding = mkLiteral "1em 1em";
                text-color = mkRgb "base05";
                background-color = mkRgba rofiOpacity "base00";
                border-radius = mkLiteral "8px";
              };
              "element-text" = {
                padding = mkLiteral "0.5em 1em";
                margin = mkLiteral "0 0.5em";
              };
              "element-icon" = {
                size = mkLiteral "3ch";
              };
              "element-text selected" = {
                background-color = mkRgba rofiOpacity "base0A";
                text-color = mkRgb "base01";
                border-radius = mkLiteral "8px";
              };
            };
        };

        programs.niri =
          with config.lib.niri.actions;
          let
            dms = "${lib.getExe config.programs.dank-material-shell.package}";
            ipc =
              xs:
              [
                dms
                "ipc"
                "call"
              ]
              ++ xs;
          in
          {
            package = pkgs.niri;
            settings = {
              includes = [
                ./blur.kdl
              ]
              ++ lib.optionals (!cfg.reduceMotion) [ ./anim.kdl ];
              prefer-no-csd = true;
              window-rules = [
                {
                  geometry-corner-radius = {
                    top-left = 8.0;
                    top-right = 8.0;
                    bottom-right = 8.0;
                    bottom-left = 8.0;
                  };
                  clip-to-geometry = true;
                  open-fullscreen = false;
                  draw-border-with-background = false;
                  opacity = 0.95;
                }
              ];
              layout = {
                gaps = 8.0;
                empty-workspace-above-first = true;
                always-center-single-column = true;
                default-column-width.proportion = 0.5;
                preset-column-widths = [
                  { proportion = 0.33333; }
                  { proportion = 0.5; }
                  { proportion = 0.66667; }
                ];
                preset-window-heights = [
                  { proportion = 0.33333; }
                  { proportion = 0.5; }
                  { proportion = 0.66667; }
                  { proportion = 1.0; }
                ];
                border = {
                  enable = false;
                };
                focus-ring = {
                  enable = true;
                  width = 2.0;
                  active.gradient = {
                    from = "${config.lib.stylix.colors.withHashtag.base0A}";
                    to = "${config.lib.stylix.colors.withHashtag.base09}";
                  };
                  # inactive.gradient = {
                  #   from = "${config.lib.stylix.colors.withHashtag.base01}";
                  #   to = "${config.lib.stylix.colors.withHashtag.base02}";
                  # };
                };
              };
              input.touchpad = {
                tap = false;
              };
              binds = {
                "Mod+D" = {
                  repeat = false;
                  action = toggle-overview;
                };

                "Mod+BackSpace" = {
                  repeat = false;
                  action.spawn = ipc [
                    "powermenu"
                    "toggle"
                  ];
                };

                "Mod+V" = {
                  repeat = false;
                  action.spawn = ipc [
                    "clipboard"
                    "toggle"
                  ];
                };

                "Mod+N" = {
                  repeat = false;
                  action.spawn = ipc [
                    "notifications"
                    "toggle"
                  ];
                };

                "Mod+H".action = focus-column-left;
                "Mod+J".action = focus-window-down;
                "Mod+K".action = focus-window-up;
                "Mod+L".action = focus-column-right;

                "Mod+Shift+H".action = move-column-left;
                "Mod+Shift+J".action = move-window-down;
                "Mod+Shift+K".action = move-window-up;
                "Mod+Shift+L".action = move-column-right;

                "Mod+Ctrl+H".action = focus-monitor-left;
                "Mod+Ctrl+J".action = focus-monitor-down;
                "Mod+Ctrl+K".action = focus-monitor-up;
                "Mod+Ctrl+L".action = focus-monitor-right;

                "Mod+I".action = focus-workspace-up;
                "Mod+U".action = focus-workspace-down;

                "Mod+Shift+I".action = move-column-to-workspace-up;
                "Mod+Shift+U".action = move-column-to-workspace-down;

                "Mod+Ctrl+I".action = move-workspace-up;
                "Mod+Ctrl+U".action = move-workspace-down;

                "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
                "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
                "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
                "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

                "Mod+R".action.spawn-sh = "${lib.getExe pkgs.pavucontrol} -t 3";

                "Mod+comma".action = consume-or-expel-window-left;
                "Mod+period".action = consume-or-expel-window-right;
                "Mod+slash".action = expel-window-from-column;

                "Mod+semicolon".action = switch-preset-column-width;
                "Mod+apostrophe".action = switch-preset-window-height;

                "Mod+C".action = center-column;
                "Mod+Ctrl+C".action = center-visible-columns;

                "Mod+return".action = fullscreen-window;
                "Mod+f".action = maximize-column;
                "Mod+shift+f".action = maximize-window-to-edges;

                "Mod+P".action.spawn-sh =
                  ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.swappy} -f -'';
                "Mod+T".action.spawn = "${lib.getExe pkgs.kitty}";
                "Mod+Shift+P".action.spawn-sh = "${lib.getExe pkgs.grim} - | ${lib.getExe pkgs.swappy} -f -";
                "Mod+B".action.spawn = "${lib.getExe config.functorOS.programs.defaultBrowser}";
                "Mod+M".action.spawn = "${lib.getExe pkgs.thunderbird}";
                "Mod+E".action.spawn = "${lib.getExe pkgs.nautilus}";
                "Super+x".action.spawn-sh = "pkill -x rofi || rofi -show window";

                "Mod+Space" = {
                  hotkey-overlay.title = "Application Launcher";
                  action.spawn = ipc [
                    "spotlight"
                    "toggle"
                  ];
                };

                "Mod+Q".action = close-window;

                "XF86MonBrightnessDown" = {
                  allow-when-locked = true;
                  action.spawn = ipc [
                    "brightness"
                    "decrement"
                    "5"
                    ""
                  ];
                };
                "XF86MonBrightnessUp" = {
                  allow-when-locked = true;
                  action.spawn = ipc [
                    "brightness"
                    "increment"
                    "5"
                    ""
                  ];
                };
                "XF86AudioRaiseVolume" = {
                  allow-when-locked = true;
                  action.spawn = ipc [
                    "audio"
                    "increment"
                    "3"
                  ];
                };
                "XF86AudioLowerVolume" = {
                  allow-when-locked = true;
                  action.spawn = ipc [
                    "audio"
                    "decrement"
                    "3"
                  ];
                };
                "XF86AudioMute" = {
                  allow-when-locked = true;
                  action.spawn = ipc [
                    "audio"
                    "mute"
                  ];
                };
                "XF86AudioPlay".action.spawn-sh = "${lib.getExe pkgs.playerctl} --player=%any,firefox play-pause";
                "XF86AudioNext".action.spawn-sh = "${lib.getExe pkgs.playerctl} --player=%any,firefox next";
                "XF86AudioRewind".action.spawn-sh = "${lib.getExe pkgs.playerctl} --player=%any,firefox previous";
              };
            };
          };
      }
    ]
  );
}
