{ config, lib, ... }:
let
  cfg = config.functorOS.desktop.hyprland;
in
{
  config.wayland.windowManager.hyprland.settings.windowrulev2 =
    lib.mkIf config.functorOS.desktop.hyprland.enable
      (
        [
          "match:class ^(librewolf)$,opacity 0.90 0.90"
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
          "opacity 0.80 0.80,match:initial_title ^(Spotify Premium)$"
          "opacity 0.80 0.80,match:initial_title ^(Spotify Free)$"
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
          "match:class class:^(com.github.tchx84.Flatseal)$, opacity 0.80 0.80, # Flatseal-Gtk"
          "match:class class:^(hu.kramo.Cartridges)$, opacity 0.80 0.80, # Cartridges-Gtk"
          "match:class class:^(com.obsproject.Studio)$, opacity 0.80 0.80, # Obs-Qt"
          "match:class class:^(gnome-boxes)$, opacity 0.80 0.80, # Boxes-Gtk"
          "match:class class:^(discord)$, opacity 0.80 0.80, # Discord-Electron"
          "match:class class:^(vesktop)$, opacity 0.80 0.80, # Vesktop-Electron"
          "match:class class:^(Element)$, opacity 0.80 0.80, # Vesktop-Electron"
          "match:class class:^(ArmCord)$, opacity 0.80 0.80, # ArmCord-Electron"
          "match:class class:^(app.drey.Warp)$, opacity 0.80 0.80, # Warp-Gtk"
          "match:class class:^(net.davidotek.pupgui2)$, opacity 0.80 0.80, # ProtonUp-Qt"
          "match:class class:^(yad)$, opacity 0.80 0.80, # Protontricks-Gtk"
          "match:class class:^(signal)$, opacity 0.80 0.80, # Signal-Gtk"
          "match:class class:^(io.github.alainm23.planify)$, opacity 0.80 0.80, # planify-Gtk"
          "match:class class:^(io.gitlab.theevilskeleton.Upscaler)$, opacity 0.80 0.80, # Upscaler-Gtk"
          "match:class class:^(com.github.unrud.VideoDownloader)$, opacity 0.80 0.80, # VideoDownloader-Gtk"
          "match:class class:^(lutris)$, opacity 0.80 0.80, # Lutris game launcher"

          "match:class ^(pavucontrol)$, opacity 0.80 0.70"
          "match:class ^(blueman-manager)$, opacity 0.80 0.70"
          "match:class ^(nm-applet)$, opacity 0.80 0.70"
          "match:class ^(nm-connection-editor)$, opacity 0.80 0.70"
          "match:class ^(org.kde.polkit-kde-authentication-agent-1)$, opacity 0.80 0.70"

          "float,match:class ^(org.kde.dolphin)$,match:title:^(Progress Dialog — Dolphin)$"
          "float,match:class ^(org.kde.dolphin)$,match:title:^(Copying — Dolphin)$"
          "float,match:title ^(Picture-in-Picture)$"
          "float,match:class ^(librewolf)$,match:title:^(Library)$"
          "float,match:class ^(floorp)$,match:title:^(Library)$"
          "float,match:class ^(zen-alpha)$,match:title:^(Library)$"
          "float,match:class ^(zen-beta)$,match:title:^(Library)$"
          "float,match:class ^(zen)$,match:title:^(Library)$"
          ''float,match:class ^(zen)$,match:title:^(.*Extension: \(Bitwarden Password Manager\).*)$''
          "float,match:class ^(vlc)$"
          "float,match:class ^(kvantummanager)$"
          "float,match:class ^(qt5ct)$"
          "float,match:class ^(qt6ct)$"
          "float,match:class ^(nwg-look)$"
          "float,match:class ^(org.kde.ark)$"
          "float,match:class ^(org.pulseaudio.pavucontrol)$"
          "float,match:class ^(com.github.rafostar.Clapper)$ # Clapper-Gtk"
          "float,match:class ^(app.drey.Warp)$ # Warp-Gtk"
          "float,match:class ^(net.davidotek.pupgui2)$ # ProtonUp-Qt"
          "float,match:class ^(yad)$ # Protontricks-Gtk"
          "float,match:class ^(eog)$ # Imageviewer-Gtk"
          "float,match:class ^(io.github.alainm23.planify)$ # planify-Gtk"
          "float,match:class ^(io.gitlab.theevilskeleton.Upscaler)$ # Upscaler-Gtk"
          "float,match:class ^(com.github.unrud.VideoDownloader)$ # VideoDownloader-Gkk"
          "float,match:class ^(blueman-manager)$"
          "float,match:class ^(nm-applet)$"
          "float,match:class ^(nm-connection-editor)$"
          "float,match:class ^(org.kde.polkit-kde-authentication-agent-1)$"
          "opacity 0.80 0.80,match:class ^(org.freedesktop.impl.portal.desktop.gtk)$"
          "opacity 0.80 0.80,match:class ^(org.freedesktop.impl.portal.desktop.hyprland)$"

          ''size 70% 70%,match:class ^(zen)$,match:title:^(.*Extension: \(Bitwarden Password Manager\).*)$''
          "size 50% 50%,match:class ^(org.pulseaudio.pavucontrol)"

          "stayfocused, match:class ^(pinentry-)" # fix pinentry losing focus
        ]
        ++ (lib.optionals cfg.fcitx5.enable [
          "pseudo, match:class ^(fcitx)"
        ])
      );
}
