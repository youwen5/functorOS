{
  config,
  lib,
  ...
}:
let
  cfg = config.functorOS.wsl;
in
{
  options.functorOS.wsl = {
    enable = lib.mkEnableOption "WSL";
  };

  config = {
    security.polkit = {
      enable = cfg.enable;
      extraConfig = lib.mkIf cfg.enable ''
        polkit.addRule((action, subject) => {
          if (
            (action.id == "org.freedesktop.systemd1.manage-units" ||
            action.id == "org.freedesktop.systemd1.manage-unit-files") &&
            subject.isInGroup("wheel")
          ) {
            return polkit.Result.YES;
          }
        });
      '';
    };
    
    wsl = lib.mkIf cfg.enable {
      enable = true;
      defaultUser = config.functorOS.username;
      useWindowsDriver = true;
    };
  };
}
