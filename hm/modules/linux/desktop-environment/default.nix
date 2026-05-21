{
  osConfig,
  lib,
  ...
}:
{
  imports = [
    ./niri
    ./dms-shell
  ];

  options.functorOS.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.functorOS.desktop.enable;
      description = ''
        Whether to enable the default configuration for the userland portions of the functorOS desktop environment.
      '';
    };
  };
}
