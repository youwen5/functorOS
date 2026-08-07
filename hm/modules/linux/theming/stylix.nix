{ osConfig, lib, ... }:
{
  config = lib.mkIf osConfig.functorOS.theming.enable {};
}
