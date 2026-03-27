{
  osConfig,
  pkgs,
  ...
}:
{
  imports = [ ./stylix.nix ];
  gtk = {
    enable = true;
    gtk4.theme = null;
    iconTheme = {
      name = 
        if (osConfig.stylix.polarity == "dark") then
          "Papirus-Dark"
        else
          "Papirus-Light";
    };
  };
}
