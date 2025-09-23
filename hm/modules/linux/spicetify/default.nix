{
  spicepkgs,
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  config =
    lib.mkIf
      (
        config.functorOS.programs.enable
        && osConfig.functorOS.config.allowUnfree
        && pkgs.stdenv.hostPlatform.isLinux
        && pkgs.stdenv.hostPlatform.isx86_64
      )
      {
        programs.spicetify = {
          enable = true;
          # theme = spicepkgs.themes.dribbblish;
          # colorScheme = "rosepine";
          enabledExtensions = with spicepkgs.extensions; [
            lastfm
            fullAppDisplayMod
            adblock
            shuffle
            fullAlbumDate
            featureShuffle
            showQueueDuration
          ];
          enabledCustomApps = with spicepkgs.apps; [
            lyricsPlus
          ];
        };
      };
}

