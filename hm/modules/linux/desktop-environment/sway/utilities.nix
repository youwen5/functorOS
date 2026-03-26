{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  cfg = config.functorOS.desktop.sway;
in
{
  config = lib.mkIf cfg.enable {
    # --- Wallpaper ---
    wayland.windowManager.sway.config.output =
      if osConfig.functorOS.theming.enable then
        {
          "*" = {
            bg = "${config.stylix.image} fill";
          };
        }
      else
        {
          "*" = {
            bg = "#${config.lib.stylix.colors.base00} solid_color";
          };
        };

    # --- Blue light filter ---
    systemd.user.services = lib.mkIf cfg.bluelight.enable {
      wlsunset = {
        Unit = {
          Description = "Blue light filter daemon";
          PartOf = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          Type = "simple";
          ExecStart = "${lib.getExe pkgs.wlsunset} -t 4500 -T 6500 -l 0 -L 0";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };

    # --- Screen locker ---
    programs.hyprlock = lib.mkIf cfg.screenlocker.enable {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          grace = 0;
        };
        background = {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 7;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        };
        input-field = {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = false;
          dots_rounding = -1;
          outer_color = "rgb(151515)";
          inner_color = "rgb(200, 200, 200)";
          font_color = "rgb(10, 10, 10)";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Input Password...</i>";
          hide_input = false;
          rounding = -1;
          check_color = "rgb(204, 136, 34)";
          fail_color = "rgb(204, 34, 34)";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_timeout = 2000;
          fail_transition = 300;
          capslock_color = -1;
          numlock_color = -1;
          bothlock_color = -1;
          invert_numlock = false;
          swap_font_color = false;
          position = "0, -20";
          halign = "center";
          valign = "center";
        };
      };
    };

    # --- Idle daemon ---
    services.swayidle = lib.mkIf cfg.idleDaemon.enable {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "loginctl lock-session";
        }
        {
          event = "lock";
          command = "${lib.getExe pkgs.hyprlock}";
        }
      ];
      timeouts = [
        {
          timeout = 1500;
          command = "loginctl lock-session";
        }
        {
          timeout = 330;
          command = "swaymsg 'output * dpms off'";
          resumeCommand = "swaymsg 'output * dpms on'";
        }
        {
          timeout = 1800;
          command = "systemctl suspend";
        }
      ];
    };

    # --- OSD (volume/brightness visual feedback) ---
    services.swayosd.enable = true;

    # --- App launcher ---
    programs.rofi = {
      enable = true;
      terminal = "${lib.getExe pkgs.kitty}";
      extraConfig = {
        prompt = ">";
      };
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
            background-color = mkLiteral "transparent";
          };
          "window" = {
            height = mkLiteral "20em";
            width = mkLiteral "30em";
            border-radius = mkLiteral "0px";
            border = mkLiteral "1px";
            border-color = mkRgb "base05";
            background-color = mkRgba rofiOpacity "base00";
            padding = mkLiteral "0";
          };
          "mainbox" = {
            background-color = mkLiteral "transparent";
            spacing = mkLiteral "0";
            padding = mkLiteral "0";
          };
          "inputbar" = {
            padding = mkLiteral "0.6em 1em";
            background-color = mkRgba rofiOpacity "base00";
            border = mkLiteral "0px 0px 1px 0px";
            border-color = mkRgb "base05";
            spacing = mkLiteral "0.5em";
          };
          "prompt" = {
            enabled = true;
            text-color = mkRgb "base0B";
            padding = mkLiteral "0";
          };
          "entry" = {
            placeholder = "search...";
            placeholder-color = mkRgba "40" "base05";
            padding = mkLiteral "0";
            text-color = mkRgb "base05";
            background-color = mkLiteral "transparent";
            border-radius = mkLiteral "0px";
          };
          "listview" = {
            padding = mkLiteral "0.5em 0";
            background-color = mkLiteral "transparent";
          };
          "element" = {
            padding = mkLiteral "0.35em 1em";
            border-radius = mkLiteral "0px";
            background-color = mkLiteral "transparent";
            spacing = mkLiteral "0.5em";
          };
          "element-icon" = {
            size = mkLiteral "3ch";
            background-color = mkLiteral "transparent";
          };
          "element-text" = {
            padding = mkLiteral "0";
            background-color = mkLiteral "transparent";
            text-color = mkRgb "base05";
          };
          "element-text selected" = {
            background-color = mkRgba "25" "base0B";
            text-color = mkRgb "base0B";
            border-radius = mkLiteral "0px";
          };
        };
    };

    # --- Logout menu ---
    programs.wlogout.enable = true;
  };
}
