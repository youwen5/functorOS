{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.functorOS.desktop.waybar;
  theme = config.lib.stylix;
  palette = theme.colors;
  useSway = config.functorOS.desktop.sway.enable;
  wsModuleName = if useSway then "sway/workspaces" else "hyprland/workspaces";
in
{
  options.functorOS.desktop.waybar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.functorOS.desktop.enable;
      description = ''
        Whether to enable Waybar and the functorOS rice.
      '';
    };
    variant = lib.mkOption {
      type = lib.types.enum [
        "full"
        "minimal"
        "laptop"
        "compact"
      ];
      default = if osConfig.functorOS.formFactor == "laptop" then "laptop" else "full";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ playerctl ];
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target =
        if useSway then
          "sway-session.target"
        else if config.functorOS.desktop.hyprland.enable then
          "hyprland-session.target"
        else
          "graphical-session.target";
      settings.mainBar = {
        name = "bar0";
        reload_style_on_change = true;
        position = "top";
        layer = "top";
        height = if cfg.variant == "compact" then 30 else 37;
        margin-top = if cfg.variant == "compact" then 0 else 8;
        margin-bottom = 0;
        margin-left = if cfg.variant == "compact" then 0 else 8;
        margin-right = if cfg.variant == "compact" then 0 else 8;
        modules-left =
          [
            "custom/launcher"
          ]
          ++ (lib.optionals (cfg.variant != "laptop" && cfg.variant != "compact") [
            "custom/playerctl#backward"
            "custom/playerctl#play"
            "custom/playerctl#forward"
          ])
          ++ [
            "idle_inhibitor"
          ]
          ++ (lib.optionals (cfg.variant == "laptop" || cfg.variant == "compact") [
            wsModuleName
          ])
          ++ (lib.optionals (cfg.variant == "minimal") [
            "cava#left"
          ])
          ++ [
            "custom/playerlabel"
          ];
        modules-center = lib.mkIf (cfg.variant != "laptop" && cfg.variant != "compact") (
          (lib.optionals (cfg.variant == "full") [
            "cava#left"
          ])
          ++ [
            wsModuleName
          ]
          ++ (lib.optionals (cfg.variant == "full") [
            "cava#right"
          ])
        );
        modules-right =
          [
            "tray"
            "battery"
          ]
          ++ (lib.optionals useSway [
            "cpu"
            "memory"
          ])
          ++ [
            "pulseaudio"
            "network"
            "clock"
          ];
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰛊 ";
            deactivated = "󰾫 ";
          };
        };
        clock = {
          format = " {:%a, %d %b, %I:%M %p}";
          tooltip = "true";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = " {:%d/%m}";
        };
        "${wsModuleName}" =
          if useSway then
            {
              disable-scroll = false;
              all-outputs = false;
              on-scroll-down = "swaymsg workspace next_on_output";
              on-scroll-up = "swaymsg workspace prev_on_output";
              format = "{name}";
              format-icons = {
                urgent = "!";
              };
            }
          else
            {
              disable-scroll = false;
              on-scroll-down = "${lib.getExe pkgs.hyprnome}";
              on-scroll-up = "${lib.getExe pkgs.hyprnome} --previous";
              format = "{icon}";
              on-click = "activate";
              format-icons = {
                active = "";
                default = "";
                urgent = "";
                special = "󰠱";
              };
              sort-by-number = true;
            };
        "cava#left" = {
          framerate = 60;
          autosens = 1;
          bars = 18;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          method = "pipewire";
          source = "auto";
          stereo = true;
          reverse = false;
          bar_delimiter = 0;
          monstercat = false;
          waves = false;
          input_delay = 2;
          format-icons = [
            "<span foreground='#${palette.base08}'>▁</span>"
            "<span foreground='#${palette.base08}'>▂</span>"
            "<span foreground='#${palette.base08}'>▃</span>"
            "<span foreground='#${palette.base08}'>▄</span>"
            "<span foreground='#${palette.base0A}'>▅</span>"
            "<span foreground='#${palette.base0A}'>▆</span>"
            "<span foreground='#${palette.base0A}'>▇</span>"
            "<span foreground='#${palette.base0A}'>█</span>"
          ];
        };
        "cava#right" = {
          framerate = 60;
          autosens = 1;
          bars = 18;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          method = "pipewire";
          source = "auto";
          stereo = true;
          reverse = false;
          bar_delimiter = 0;
          monstercat = false;
          waves = false;
          input_delay = 2;
          format-icons = [
            "<span foreground='#${palette.base08}'>▁</span>"
            "<span foreground='#${palette.base08}'>▂</span>"
            "<span foreground='#${palette.base08}'>▃</span>"
            "<span foreground='#${palette.base08}'>▄</span>"
            "<span foreground='#${palette.base0A}'>▅</span>"
            "<span foreground='#${palette.base0A}'>▆</span>"
            "<span foreground='#${palette.base0A}'>▇</span>"
            "<span foreground='#${palette.base0A}'>█</span>"
          ];
        };
        "custom/playerctl#backward" = {
          format = "󰙣 ";
          on-click = "playerctl previous";
          on-scroll-up = "playerctl volume .05+";
          on-scroll-down = "playerctl volume .05-";
        };
        "custom/playerctl#play" = {
          format = "{icon}";
          return-type = "json";
          exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl volume .05+";
          on-scroll-down = "playerctl volume .05-";
          format-icons = {
            Playing = "<span>󰏥 </span>";
            Paused = "<span> </span>";
            Stopped = "<span> </span>";
          };
        };
        "custom/playerctl#forward" = {
          format = "󰙡 ";
          on-click = "playerctl next";
          on-scroll-up = "playerctl volume .05+";
          on-scroll-down = "playerctl volume .05-";
        };
        "custom/playerlabel" = {
          format = "<span>󰎈 {} 󰎈</span>";
          return-type = "json";
          max-length = 40;
          exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click = "";
        };
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "  {capacity}%";
          format-plugged = " {capacity}% ";
          format-alt = "{icon} {time}";
          format-icons = [
            "󰁺"
            "󰁼"
            "󰁾"
            "󰂀"
            "󰁹"
          ];
        };

        memory = {
          format = "󰍛 {}%";
          format-alt = "󰍛 {used}/{total} GiB";
          interval = 5;
          tooltip = true;
          tooltip-format = "RAM: {used} GiB / {total} GiB";
        };
        cpu = {
          format = "󰻠 {usage}%";
          format-alt = "󰻠 {avg_frequency} GHz";
          interval = 5;
          tooltip = true;
          tooltip-format = "CPU: {usage}% | {avg_frequency} GHz";
        };
        network = {
          format-wifi = "󰤨 {signalStrength}%";
          format-ethernet = "󰈀 100% ";
          tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "󰖪 0% ";
        };
        tray = {
          icon-size = 20;
          spacing = 8;
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          scroll-step = 5;
          on-click = "${lib.getExe pkgs.pavucontrol}";
        };
        "custom/launcher" =
          let
            toggle-colorscheme = pkgs.writeShellScriptBin "toggle-colorscheme.sh" ''
              POLARITY_FILE="/etc/polarity"

              if [[ ! -f "$POLARITY_FILE" ]]; then
                exit 0
              elif [[ ! -r "$POLARITY_FILE" ]]; then
                echo "Error: Cannot read $POLARITY_FILE. Check permissions." >&2
                exit 1
              fi

              current_scheme=$(cat "$POLARITY_FILE")
              if [[ $? -ne 0 ]]; then
                  echo "Error: Failed to read content from $POLARITY_FILE." >&2
                  exit 1
              fi

              current_scheme=$(echo "$current_scheme" | xargs)

              target_service=""
              case "$current_scheme" in
                dawn)
                  target_service="colorscheme-dusk.service"
                  ;;
                dusk)
                  target_service="colorscheme-dawn.service"
                  ;;
                *)
                  echo "Error: Invalid content '$current_scheme' found in $POLARITY_FILE. Expected 'dawn' or 'dusk'." >&2
                  exit 1
                  ;;
              esac

              echo "Current scheme: '$current_scheme'. Attempting to start '$target_service'..."
              systemctl start "$target_service"

              if [[ $? -ne 0 ]]; then
                echo "Error: Failed to execute 'systemctl start $target_service'. Check systemctl logs or permissions." >&2
                exit 1
              else
                echo "Command 'systemctl start $target_service' executed successfully."
              fi

              exit 0
            '';
          in
          {
            format = "";
            on-click = "pkill -9 rofi || rofi -show drun";
            on-click-right = "${lib.getExe toggle-colorscheme}";
            tooltip = "false";
          };
      };
      style =
        let
          mkRgba =
            opacity: color:
            let
              c = config.lib.stylix.colors;
              r = c."${color}-rgb-r";
              g = c."${color}-rgb-g";
              b = c."${color}-rgb-b";
            in
            "rgba(${r}, ${g}, ${b}, ${opacity})";
          compact = cfg.variant == "compact";
        in
        # ── Shared base styles (hyprland default) ──────────────────────────
        ''
          * {
            border: none;
            border-radius: 0px;
            font-family: GeistMono Nerd Font;
            font-size: ${if compact then "12px" else "13px"};
            min-height: 0;
          }
          window#waybar {
            background: transparent;
            opacity: 0.9;
            ${if compact then "" else "border-radius: 24px;"}
          }

          #waybar > box {
            background: ${mkRgba "0.6" "base01"};
            border-radius: 24px;
          }

          #cava.left, #cava.right {
              background: #${palette.base00};
              margin: 4px;
              padding: 6px 16px;
              color: #${palette.base00};
          }
          #cava.left {
              border-radius: 16px;
              border-color: #${palette.base03};
              border-style: solid;
              border-width: 2px;
          }
          #cava.right {
              border-radius: 16px;
              border-color: #${palette.base03};
              border-style: solid;
              border-width: 2px;
          }
          #workspaces {
              background: #${palette.base00};
              color: #${palette.base00}
          }
          #workspaces button {
              padding: 0px 5px;
              margin: 0px 3px;
              border-radius: 16px;
              color: transparent;
              background: #${palette.base03};
              transition: all 0.3s ease-in-out;
          }

          #workspaces button.active,
          #workspaces button.focused {
              background-color: #${palette.base0A};
              color: #${palette.base03};
              border-radius: 16px;
              min-width: 50px;
              background-size: 400% 400%;
              transition: all 0.3s ease-in-out;
          }

          #workspaces button:hover {
              background-color: #${palette.base05};
              color: #${palette.base05};
              border-radius: 16px;
              min-width: 50px;
              background-size: 400% 400%;
          }

          #tray, #pulseaudio, #network, #battery,
          #custom-playerctl.backward, #custom-playerctl.play, #custom-playerctl.forward{
              background: #${palette.base00};
              font-weight: bold;
              margin: 4px 0px;
          }
          #tray, #pulseaudio, #network, #battery{
              color: #${palette.base05};
              border-radius: 16px;
              border-color: #${palette.base03};
              border-style: solid;
              border-width: 2px;
              padding: 0 20px;
              margin-left: 7px;
          }
          #clock {
              color: #${palette.base05};
              background: #${palette.base00};
              ${
                if compact then "border-radius: 18px 0px 0px 18px;" else "border-radius: 18px 12px 12px 18px;"
              }
              ${if compact then "padding: 6px 20px 6px 20px;" else "padding: 8px 25px 8px 25px;"}
              margin-left: 7px;
              font-weight: bold;
              font-size: ${if compact then "13px" else "14px"};
          }
          #custom-launcher {
              color: #${palette.base0A};
              background: #${palette.base00};
              ${
                if compact then "border-radius: 0px 18px 18px 0px;" else "border-radius: 12px 18px 18px 12px;"
              }
              margin: 0px;
              ${if compact then "padding: 0px 30px 0px 20px;" else "padding: 0px 35px 0px 25px;"}
              font-size: 24px;
          }

          #custom-playerctl.backward, #custom-playerctl.play, #custom-playerctl.forward {
              background: #${palette.base00};
              font-size: 20px;
          }
          #custom-playerctl.backward:hover, #custom-playerctl.play:hover, #custom-playerctl.forward:hover{
              color: #${palette.base00};
          }
          #custom-playerctl.backward {
              color: #${palette.base08};
              border-radius: 16px 0px 0px 16px;
              border-color: #${palette.base03} #${palette.base00} #${palette.base03} #${palette.base03};
              border-style: solid;
              border-width: 2px 0px 2px 2px;
              padding-left: 16px;
              margin-left: 7px;
          }
          #custom-playerctl.play {
              color: #${palette.base0A};
              padding: 0 5px;
              border-color: #${palette.base03} #${palette.base00} #${palette.base03} #${palette.base00};
              border-style: solid;
              border-width: 2px 0px 2px 0px;
          }
          #custom-playerctl.forward {
              color: #${palette.base08};
              border-radius: 0px 16px 16px 0px;
              border-color: #${palette.base03} #${palette.base03} #${palette.base03} #${palette.base00};
              border-style: solid;
              border-width: 2px 2px 2px 0px;
              padding-right: 12px;
              margin-right: 7px
          }
          #custom-playerlabel {
              background: #${palette.base00};
              color: #${palette.base05};
              padding: 0 20px;
              border-radius: 16px;
              border-color: #${palette.base03};
              border-style: solid;
              border-width: 2px;
              margin: 4px 0;
              font-weight: bold;
          }
          #idle_inhibitor {
              background: #${palette.base00};
              color: #${palette.base05};
              padding: 0 10px 0 15px;
              border-radius: 16px;
              border-color: #${palette.base03};
              border-style: solid;
              border-width: 2px;
              margin: 4px 7px 4px 0;
              font-weight: bold;
          }
          #window{
              background: #${palette.base00};
              padding-left: 15px;
              padding-right: 15px;
              border-radius: 16px;
              margin-top: 4px;
              margin-bottom: 4px;
              font-weight: normal;
              font-style: normal;
          }
        ''
        + (lib.optionalString (cfg.variant == "laptop" || cfg.variant == "compact") ''
          #workspaces {
            margin: 4px;
            padding: 6px 16px;
            border-radius: 16px;
            border-color: #${palette.base03};
            border-style: solid;
            border-width: 2px;
          }
        '')
        + (lib.optionalString (cfg.variant != "laptop" && cfg.variant != "compact") ''
          #workspaces {
            margin: 4px 5px;
            padding: 6px 5px;
            border-radius: 16px;
            border-width: 2px;
            border-color: #${palette.base03};
            border-style: solid;
          }
        '')
        # ── Sway overrides: squared-off, utilitarian ───────────────────────
        + (lib.optionalString useSway ''
          /* Sway: fully squared off — no border-radius anywhere */
          window#waybar {
            border-radius: 0px;
          }
          #waybar > box {
            border-radius: 0px;
            border-bottom: 2px solid #${palette.base03};
          }
          #workspaces,
          #workspaces button,
          #workspaces button.focused,
          #workspaces button.active,
          #workspaces button:hover,
          #tray, #pulseaudio, #network, #battery,
          #cpu, #memory,
          #clock,
          #custom-launcher,
          #custom-playerlabel,
          #idle_inhibitor,
          #window,
          #custom-playerctl.backward,
          #custom-playerctl.play,
          #custom-playerctl.forward {
            border-radius: 0px;
          }

          /* Sway workspace buttons: underline style instead of pill */
          #workspaces {
            margin: 0px 4px;
            padding: 0px 4px;
            border-radius: 0px;
            border-color: transparent;
            border-style: solid;
            border-width: 0px;
          }
          #workspaces button {
            padding: 0px 8px;
            margin: 0px 1px;
            background: transparent;
            color: #${palette.base04};
            border-bottom: 2px solid transparent;
            transition: all 0.15s ease-in-out;
          }
          #workspaces button.focused,
          #workspaces button.active {
            background: #${palette.base01};
            color: #${palette.base0A};
            border-bottom: 2px solid #${palette.base0A};
            min-width: 40px;
          }
          #workspaces button.urgent {
            background: #${palette.base08};
            color: #${palette.base00};
            border-bottom: 2px solid #${palette.base08};
          }
          #workspaces button:hover {
            background: #${palette.base02};
            color: #${palette.base05};
            border-bottom: 2px solid #${palette.base05};
            min-width: 40px;
          }

          /* Sway clock: squared */
          #clock {
            border-radius: 0px;
            padding: 0px 20px 0px 14px;
            border-left: 2px solid #${palette.base03};
            border-right: none;
            border-top: none;
            border-bottom: none;
          }

          /* Sway launcher: squared */
          #custom-launcher {
            border-radius: 0px;
            padding: 0px 24px 0px 18px;
            border-right: 2px solid #${palette.base03};
            border-left: none;
            border-top: none;
            border-bottom: none;
          }

          /* Sway stats modules: CPU and memory */
          #cpu, #memory {
            background: #${palette.base00};
            font-weight: bold;
            margin: 0px;
            border-style: solid;
            border-width: 0px 0px 0px 2px;
            border-color: #${palette.base03};
            padding: 0 14px;
          }
          #cpu {
            color: #${palette.base08};
          }
          #memory {
            color: #${palette.base0D};
          }

          /* Sway right-side modules: flat with left separator */
          #tray, #pulseaudio, #network, #battery {
            border-radius: 0px;
            border-style: solid;
            border-width: 0px 0px 0px 2px;
            border-color: #${palette.base03};
            padding: 0 14px;
            margin: 0px;
            margin-left: 0px;
          }

          /* Sway idle inhibitor: squared */
          #idle_inhibitor {
            border-radius: 0px;
            border-style: solid;
            border-width: 0px 2px 0px 0px;
            border-color: #${palette.base03};
            margin: 0px;
          }

          /* Sway player label: squared */
          #custom-playerlabel {
            border-radius: 0px;
            border-style: solid;
            border-width: 0px 0px 0px 2px;
            border-color: #${palette.base03};
            padding: 0 14px;
            margin: 0px;
          }
        '');
    };
  };
}
