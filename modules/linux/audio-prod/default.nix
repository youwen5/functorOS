{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.functorOS.system.audio.prod;
  forAllUsers = lib.genAttrs cfg.realtimeAudioUsers;
in
{
  options.functorOS.system.audio.prod = {
    enable = lib.mkEnableOption "audio production";
    realtimeAudioUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.map (x: x.username) config.functorOS._users;
      description = ''
        List of users to add to the audio group for realtime capabilities.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        functorOS = {
          programs.wine.enable = true;
          system.audio.enable = true;
          config.extraUnfreePackages = lib.mkIf config.functorOS.config.allowUnfree [
            "reaper"
          ];
        };

        environment.systemPackages = with pkgs; [
          yabridge
          yabridgectl
          alsa-scarlett-gui
        ];

        musnix.enable = true;
        # PREEMPT_RT is merged into master
        musnix.kernel.realtime = false;

        musnix.das_watchdog.enable = true;
        musnix.alsaSeq.enable = true;
        musnix.rtcqs.enable = true;
        users.users = forAllUsers (_: {
          extraGroups = [ "audio" ];
        });

        boot.kernelParams = [
          "threadirqs"
        ];
      }
      (lib.mkIf config.functorOS.config.allowUnfree {
        environment.systemPackages = with pkgs; [
          (reaper.overrideAttrs (
            finalAttrs: prevAttrs: {
              # Keep relocated ELF sections clear of the original read-only LOAD
              # segment; overlapping mappings otherwise crash ld.so at DT_DEBUG.
              patchelfFlags = (prevAttrs.patchelfFlags or [ ]) ++ [
                "--page-size"
                "65536"
              ];
              installPhase = ''
                runHook preInstall

                HOME="$out/share" XDG_DATA_HOME="$out/share" ./install-reaper.sh \
                  --install $out/opt \
                  --integrate-user-desktop
                rm $out/opt/REAPER/uninstall-reaper.sh

                # Dynamic loading of plugin dependencies does not adhere to rpath of
                # reaper executable that gets modified with runtimeDependencies.
                # Patching each plugin with DT_NEEDED is cumbersome and requires
                # hardcoding of API versions of each dependency.
                # Setting the rpath of the plugin shared object files does not
                # seem to have an effect for some plugins.
                # We opt for wrapping the executable with LD_LIBRARY_PATH prefix.
                # Note that libcurl and libxml2_13 are needed for ReaPack to run.
                wrapProgram $out/opt/REAPER/reaper \
                  --prefix PIPEWIRE_LATENCY : "256/48000" \
                  --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
                  --prefix LD_LIBRARY_PATH : "${
                    lib.makeLibraryPath [
                      curl
                      lame
                      libxml2_13
                      ffmpeg-headless
                      vlc
                      xdotool
                      stdenv.cc.cc
                      openssl
                    ]
                  }"

                mkdir $out/bin
                ln -s $out/opt/REAPER/reaper $out/bin/

                # Avoid store path in Exec, since we already link to $out/bin
                substituteInPlace $out/share/applications/cockos-reaper.desktop \
                  --replace-fail "Exec=\"$out/opt/REAPER/reaper\"" "Exec=reaper"

                runHook postInstall
              '';
            }
          ))
        ];
      })
    ]
  );
}
