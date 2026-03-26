{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.functorOS.desktop.sway;
  modifier = "Mod4";
in
{
  wayland.windowManager.sway.config.keybindings = lib.mkIf cfg.enable (
    lib.mkForce (
      {
        # --- Scroller-style column navigation (mirrors hyprscrolling) ---
        "${modifier}+h" = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+k" = "focus up";
        "${modifier}+j" = "focus down";

        # Move windows between columns
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+j" = "move down";

        # Layout: toggle horizontal/vertical split ($mod+C = togglefit equivalent)
        "${modifier}+c" = "layout toggle splith splitv";
        # Fullscreen ($mod+F = fit active equivalent)
        "${modifier}+f" = "fullscreen toggle";

        # Workspace navigation (mirrors hyprnome $mod+U / $mod+I)
        "${modifier}+u" = "workspace next_on_output";
        "${modifier}+i" = "workspace prev_on_output";
        "${modifier}+Shift+u" = "move container to workspace next_on_output; workspace next_on_output";
        "${modifier}+Shift+i" = "move container to workspace prev_on_output; workspace prev_on_output";

        # --- Window actions ---
        "${modifier}+q" = "kill";
        "${modifier}+w" = "floating toggle";
        "${modifier}+Return" = "fullscreen toggle";

        # Scratchpad (special workspace equivalent)
        "${modifier}+s" = "scratchpad show";
        "${modifier}+Shift+s" = "move scratchpad";

        # Workspace back and forth ($mod+Tab)
        "${modifier}+Tab" = "workspace back_and_forth";

        # --- Utilities ---
        "${modifier}+space" = "exec pkill -x rofi || rofi -show drun";
        "${modifier}+x" = "exec pkill -x rofi || rofi -show window";
        "${modifier}+BackSpace" = "exec pkill -x wlogout || wlogout";
        "${modifier}+z" = "exec loginctl lock-session";

        # --- Media controls ---
        "XF86AudioMute" = "exec ${lib.getExe pkgs.pamixer} -t";
        "XF86AudioPlay" = "exec ${lib.getExe pkgs.playerctl} --player=%any,firefox play-pause";
        "XF86AudioNext" = "exec ${lib.getExe pkgs.playerctl} --player=%any,firefox next";
        "XF86AudioPrev" = "exec ${lib.getExe pkgs.playerctl} --player=%any,firefox previous";
        "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 5%-";
        "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set 5%+";
        "XF86AudioRaiseVolume" = "exec ${lib.getExe pkgs.pamixer} -i 5";
        "XF86AudioLowerVolume" = "exec ${lib.getExe pkgs.pamixer} -d 5";

        # --- Screenshots (same tooling as hyprland) ---
        "${modifier}+Shift+p" = "exec ${lib.getExe pkgs.grim} - | ${lib.getExe pkgs.swappy} -f -";
        "${modifier}+p" = ''exec ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.swappy} -f -'';

        # --- Browser ---
        "${modifier}+b" = "exec ${lib.getExe config.functorOS.programs.defaultBrowser}";

        # --- Resize (mirrors $mod+Alt+Direction in hyprland) ---
        "${modifier}+Mod1+l" = "resize grow width 30 px";
        "${modifier}+Mod1+h" = "resize shrink width 30 px";
        "${modifier}+Mod1+k" = "resize shrink height 30 px";
        "${modifier}+Mod1+j" = "resize grow height 30 px";
      }
      // (lib.optionalAttrs config.functorOS.desktop.swaync.enable {
        "${modifier}+n" = "exec sleep 0.1 && ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
      })
      // (lib.optionalAttrs config.functorOS.programs.enable {
        "${modifier}+r" = "exec ${lib.getExe pkgs.pavucontrol} -t 3";
        "${modifier}+t" = "exec ${lib.getExe pkgs.kitty}";
        "${modifier}+e" = "exec ${lib.getExe pkgs.nautilus}";
        "${modifier}+m" = "exec ${lib.getExe pkgs.thunderbird}";
      })
    )
  );
}
