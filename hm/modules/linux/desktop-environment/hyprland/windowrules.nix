{ config, lib, ... }:
let
  cfg = config.functorOS.desktop.hyprland;
in
{
  config.wayland.windowManager.hyprland.settings.windowrule =
    lib.mkIf config.functorOS.desktop.hyprland.enable
      (
        [
          "match:class ^(librewolf)$, opacity 0.90 0.90"
          "match:class ^(floorp)$, opacity 0.90 0.90"
          "match:class ^(firefox)$, opacity 0.90 0.90"
          "match:class ^(zen-alpha)$, opacity 0.90 0.90"
          "match:class ^(zen-beta)$, opacity 0.90 0.90"
          "match:class ^(zen)$, opacity 0.90 0.90"
          "match:class ^(Brave-browser)$, opacity 0.90 0.90"
          "match:class ^(Steam)$, opacity 0.80 0.80"
          "match:class ^(steam)$, opacity 0.80 0.80"
          "match:class ^(steamwebhelper)$, opacity 0.80 0.80"
          "match:class ^(io.github.nokse22.high-tide)$, opacity 0.80 0.80"
          "match:class ^(tidal-hifi)$, opacity 0.80 0.80"
          "match:class ^(spotify)$, opacity 0.80 0.80"
          "match:initial_title ^(Spotify Premium)$, opacity 0.80 0.80"
          "match:initial_title ^(Spotify Free)$, opacity 0.80 0.80"
          "match:class ^(code-oss)$, opacity 0.80 0.80"
          "match:class ^(Code)$, opacity 0.80 0.80"
          "match:class ^(code-url-handler)$, opacity 0.80 0.80"
          "match:class ^(code-insiders-url-handler)$, opacity 0.80 0.80"
          "match:class ^(kitty)$, opacity 0.80 0.80"
          "match:class ^(neovide)$, opacity 0.80 0.80"
          "match:class ^(org.kde.dolphin)$, opacity 0.80 0.80"
          "match:class ^(org.gnome.Nautilus)$, opacity 0.80 0.80"
          "match:class ^(org.kde.ark)$, opacity 0.80 0.80"
          "match:class ^(nwg-look)$, opacity 0.80 0.80"
          "match:class ^(qt5ct)$, opacity 0.80 0.80"
          "match:class ^(qt6ct)$, opacity 0.80 0.80"
          "match:class ^(kvantummanager)$, opacity 0.80 0.80"
          "match:class ^(waypaper)$, opacity 0.80 0.80"
          "match:class ^(org.pulseaudio.pavucontrol)$, opacity 0.80 0.80"
          "match:class ^(com.github.wwmm.easyeffects)$, opacity 0.80 0.80"
          "match:class ^(thunderbird)$, opacity 0.80 0.80"

          "match:class ^(com.github.rafostar.Clapper)$, opacity 0.90 0.90 # Clapper-Gtk"
          "match:class ^(com.github.tchx84.Flatseal)$, opacity 0.80 0.80 # Flatseal-Gtk"
          "match:class ^(hu.kramo.Cartridges)$, opacity 0.80 0.80 # Cartridges-Gtk"
          "match:class ^(com.obsproject.Studio)$, opacity 0.80 0.80 # Obs-Qt"
          "match:class ^(gnome-boxes)$, opacity 0.80 0.80 # Boxes-Gtk"
          "match:class ^(discord)$, opacity 0.80 0.80 # Discord-Electron"
          "match:class ^(vesktop)$, opacity 0.80 0.80 # Vesktop-Electron"
          "match:class ^(Element)$, opacity 0.80 0.80 # Element-Electron"
          "match:class ^(ArmCord)$, opacity 0.80 0.80 # ArmCord-Electron"
          "match:class ^(app.drey.Warp)$, opacity 0.80 0.80 # Warp-Gtk"
          "match:class ^(net.davidotek.pupgui2)$, opacity 0.80 0.80 # ProtonUp-Qt"
          "match:class ^(yad)$, opacity 0.80 0.80 # Protontricks-Gtk"
          "match:class ^(signal)$, opacity 0.80 0.80 # Signal-Gtk"
          "match:class ^(io.github.alainm23.planify)$, opacity 0.80 0.80 # planify-Gtk"
          "match:class ^(io.gitlab.theevilskeleton.Upscaler)$, opacity 0.80 0.80 # Upscaler-Gtk"
          "match:class ^(com.github.unrud.VideoDownloader)$, opacity 0.80 0.80 # VideoDownloader-Gtk"
          "match:class ^(lutris)$, opacity 0.80 0.80 # Lutris game launcher"

          "match:class ^(pavucontrol)$, opacity 0.80 0.70"
          "match:class ^(blueman-manager)$, opacity 0.80 0.70"
          "match:class ^(nm-applet)$, opacity 0.80 0.70"
          "match:class ^(nm-connection-editor)$, opacity 0.80 0.70"
          "match:class ^(org.kde.polkit-kde-authentication-agent-1)$, opacity 0.80 0.70"

          "match:class ^(org.kde.dolphin)$, match:title ^(Progress Dialog — Dolphin)$, float on"
          "match:class ^(org.kde.dolphin)$, match:title ^(Copying — Dolphin)$, float on"
          "match:title ^(Picture-in-Picture)$, float on"
          "match:class ^(librewolf)$, match:title ^(Library)$, float on"
          "match:class ^(floorp)$, match:title ^(Library)$, float on"
          "match:class ^(zen-alpha)$, match:title ^(Library)$, float on"
          "match:class ^(zen-beta)$, match:title ^(Library)$, float on"
          "match:class ^(zen)$, match:title ^(Library)$, float on"
          ''match:class ^(zen)$, match:title ^(.*Extension: \(Bitwarden Password Manager\).*)$, float on''
          "match:class ^(vlc)$, float on"
          "match:class ^(kvantummanager)$, float on"
          "match:class ^(qt5ct)$, float on"
          "match:class ^(qt6ct)$, float on"
          "match:class ^(nwg-look)$, float on"
          "match:class ^(org.kde.ark)$, float on"
          "match:class ^(org.pulseaudio.pavucontrol)$, float on"
          "match:class ^(com.github.rafostar.Clapper)$, float on # Clapper-Gtk"
          "match:class ^(app.drey.Warp)$, float on # Warp-Gtk"
          "match:class ^(net.davidotek.pupgui2)$, float on # ProtonUp-Qt"
          "match:class ^(yad)$, float on # Protontricks-Gtk"
          "match:class ^(eog)$, float on # Imageviewer-Gtk"
          "match:class ^(io.github.alainm23.planify)$, float on # planify-Gtk"
          "match:class ^(io.gitlab.theevilskeleton.Upscaler)$, float on # Upscaler-Gtk"
          "match:class ^(com.github.unrud.VideoDownloader)$, float on # VideoDownloader-Gtk"
          "match:class ^(blueman-manager)$, float on"
          "match:class ^(nm-applet)$, float on"
          "match:class ^(nm-connection-editor)$, float on"
          "match:class ^(org.kde.polkit-kde-authentication-agent-1)$, float on"
          "match:class ^(org.freedesktop.impl.portal.desktop.gtk)$, opacity 0.80 0.80"
          "match:class ^(org.freedesktop.impl.portal.desktop.hyprland)$, opacity 0.80 0.80"

          ''match:class ^(zen)$, match:title ^(.*Extension: \(Bitwarden Password Manager\).*)$, size 70% 70%''
          "match:class ^(org.pulseaudio.pavucontrol)$, size 50% 50%"

          "match:class ^(pinentry-), stay_focused on" # fix pinentry losing focus
        ]
        ++ (lib.optionals cfg.fcitx5.enable [
          "match:class ^(fcitx), pseudo on"
        ])
      );
}
