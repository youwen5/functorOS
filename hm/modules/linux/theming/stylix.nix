{ osConfig, lib, ... }:
{
  config = lib.mkIf osConfig.functorOS.theming.enable {
    stylix.targets = {
      waybar.enable = false;
      kitty.variant256Colors = true;
      neovim.enable = false;
      kde.enable = true;
      gnome.enable = true;
      starship.enable = false;
      rofi.enable = false;
      mako.enable = false;
    };
  };
}
