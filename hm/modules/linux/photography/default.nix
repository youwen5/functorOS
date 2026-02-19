{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.functorOS.suites.photography;
in
{
  options.functorOS.suites.photography = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.functorOS.desktop.enable;
      description = ''
        Whether to enable the photography suite.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      darktable
      digikam
      imagemagick
    ];
  };
}
