{
  osConfig,
  pkgs,
  ...
}:
{
  imports = [ ./stylix.nix ];
  gtk = {
    enable = true;
    iconTheme = {
      name = 
        if (osConfig.stylix.polarity == "dark") then
          "Papirus-Dark"
        else
          "Papirus-Light";
    };
  };
}
