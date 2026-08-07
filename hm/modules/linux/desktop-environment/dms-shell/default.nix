{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.functorOS.desktop.dms-shell;
in
{
  options.functorOS.desktop.dms-shell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.functorOS.desktop.niri.enable;
      description = ''
        Whether to enable and rice dms-shell w/ Niri integration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {};
}
