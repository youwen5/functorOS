{ config, ... }:
{
  imports = [ ./stylix.nix ];
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
    };
    gtk4.theme = config.gtk.theme;
  };
}
