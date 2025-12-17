{
  config,
  lib,
  ...
}:
let
  cfg = config.functorOS.utils.audio;
in
{
  options.functorOS.utils.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to enable some audio enhancements (e.g. EasyEffects).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.easyeffects.enable = true;
  };
}
