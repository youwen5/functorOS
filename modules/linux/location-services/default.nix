{
  config,
  lib,
  ...
}:
let
  cfg = config.functorOS.locationServices;
in
{
  options.functorOS.locationServices = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable all utilities powered by location services (auto timezone, etc)
      '';
    };
    autoTimezone.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to enable automatic timezone daemon
      '';
    };
    locationBackend.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to enable the underlying geoclue2 location backend. Note this MUST be enabled for other locationServices options to work, BUT you generally don't have to touch it as setting a blanket `locationServices.enable = true` is usually the right thing for most users and will enable this.
      '';
    };
  };
  config = {
    services.geoclue2.enable = cfg.locationBackend.enable;
    services.automatic-timezoned.enable = cfg.autoTimezone.enable;
    time.timeZone = lib.mkIf cfg.autoTimezone.enable (lib.mkForce null);
  };
}
