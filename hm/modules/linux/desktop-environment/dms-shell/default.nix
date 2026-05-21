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

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      systemd.restartIfChanged = true;
      niri = {
        enableKeybinds = false;
        includes.override = false;
      };
      settings = {
        acMonitorTimeout = 600;
        acLockTimeout = 900;
        acSuspendTimeout = 1800;
        acSuspendBehavior = 0;
        acProfileName = "2";
        acPostLockMonitorTimeout = 120;
        showOccupiedWorkspacesOnly = true;
        batteryMonitorTimeout = 300;
        batteryLockTimeout = 600;
        batterySuspendTimeout = 900;
        batterySuspendBehavior = 0;
        batteryProfileName = "0";
        batteryPostLockMonitorTimeout = 120;
        batteryChargeLimit = 100;
        lockBeforeSuspend = true;
        blurEnabled = true;
        blurForegroundLayers = true;
        useAutoLocation = true;
        launcherStyle = "spotlight";
        spotlightBarShowModeChips = true;
        launcherLogoMode = "os";
        motionEffect = 2;
        osdMediaPlaybackEnabled = true;
        barConfigs = [
          {
            id = "default";
            name = "Main Bar";
            enabled = true;
            position = 0;
            screenPreferences = [ "all" ];
            showOnLastDisplay = true;
            leftWidgets = [
              "launcherButton"
              "workspaceSwitcher"
              {
                id = "focusedWindow";
                enabled = true;
                focusedWindowSize = 1;
              }
              {
                id = "clock";
                enabled = true;
                clockCompactMode = true;
              }
            ];
            centerWidgets = [ ];
            rightWidgets = [
              {
                id = "systemTray";
                enabled = true;
              }
              {
                id = "music";
                enabled = true;
              }
              {
                id = "clipboard";
                enabled = true;
              }
              {
                id = "notificationButton";
                enabled = true;
              }
              {
                id = "battery";
                enabled = true;
              }
              {
                id = "controlCenterButton";
                enabled = true;
              }
            ];
            spacing = 4;
            innerPadding = 4;
            bottomGap = 0;
            transparency = 1;
            widgetTransparency = 1;
            squareCorners = false;
            noBackground = false;
            gothCornersEnabled = false;
            gothCornerRadiusOverride = false;
            gothCornerRadiusValue = 12;
            borderEnabled = false;
            borderColor = "surfaceText";
            borderOpacity = 1;
            borderThickness = 1;
            fontScale = 1;
            autoHide = false;
            autoHideDelay = 250;
            openOnOverview = false;
            visible = true;
            popupGapsAuto = true;
            popupGapsManual = 4;
          }
        ];
      };
    };
  };
}
