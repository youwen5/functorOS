{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.functorOS.system.core;
in
{
  options.functorOS.system.core = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.functorOS.enable;
      description = ''
        Whether to enable core functorOS system utilities and configurations (such as security policies, Nix options, etc)
      '';
    };
    replaceSudoWithRun0 = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to replace fully sudo with systemd-run0, systemd's replacement for sudo. Unlike sudo, sudo-rs, or doas (dedicated openbsd application subexecutor), run0 is not a setuid program and relies solely on existing polkit privilege escalation infrastructure, reducing attack surface of the machine.
      '';
    };
    waylandFixes = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to enable some Wayland fixes, like setting NIXOS_OZONE_WL to hint Electron apps to use the Wayland windowing system.
      '';
    };
    nixSaneDefaults = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to set sane defaults for Nix, such as optimization and automatic garbage collection.
      '';
    };
    useNh = lib.mkOption {
      type = lib.types.bool;
      default = cfg.nixSaneDefaults;
      description = ''
        Whether to enable the `nh` cli (yet another Nix helper), a reimplementation of some core NixOS utilities like nix-collect-garbage and nixos-rebuild. If enabled, automatic garbage collection will use `nh` instead of `nix-collect-garbage` and will be able to garbage collect `result` symlinks.
      '';
    };
    suppressWarnings = lib.mkEnableOption "suppress warnings";
    bluetooth.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to enable bluetooth and blueman.
      '';
    };
    uutils.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to replace GNU coreutils with Rust uutils
      '';
    };
    useGvfs.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to enable the GVFS and alias `rm` to send files to trash instead.
      '';
    };
    chinaOptimizations = lib.mkEnableOption "optimizations for Nix operations in Mainland China. e.g. use the Tsinghua University binary cache, set firewall options to tunnel Nix binary cache operations past Mullvad VPN to preven throttling.";
    customOSName = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Whether to set the OS string to functorOS instead of NixOS. This means tools like neofetch/fastfetch will report your operating system as functorOS rather than NixOS. Note that we also patch fastfetch to display a custom logo if this is enabled.
      '';
    };
  };

  options.system.nixos.codeName = lib.mkOption {
    readOnly = false;
    internal = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      (with pkgs; [
        wget
        git
        curl
      ])
      ++ [
        config.functorOS.defaultEditor
      ]
      ++ lib.optionals cfg.uutils.enable [
        (lib.hiPrio pkgs.uutils-coreutils-noprefix)
      ];

    # tells electron apps to use Wayland
    environment.sessionVariables = lib.mkIf cfg.waylandFixes {
      NIXOS_OZONE_WL = "1";
    };

    security.polkit.persistentAuthentication = cfg.replaceSudoWithRun0;
    security.run0-sudo-shim.enable = cfg.replaceSudoWithRun0;

    services.gnome.gnome-keyring.enable = true;

    services.resolved.enable = true;

    nix = lib.mkIf cfg.nixSaneDefaults {
      gc = lib.mkIf (!cfg.useNh) {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      optimise.automatic = true;
      # Free up to 1GiB when there is less than 100MiB left
      extraOptions = ''
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters =
          if cfg.chinaOptimizations then
            (lib.mkForce [
              "https://mirrors4.tuna.tsinghua.edu.cn/nix-channels/store?priority=1"
              "https://cache.nixos.org?priority=2"
              "https://nix-community.cachix.org?priority=3"
            ])
          else
            [ "https://nix-community.cachix.org" ];
        trusted-users = [ "@wheel" ];
        trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      };

      channel.enable = false;
    };

    system.nixos = lib.mkIf cfg.customOSName {
      distroName = "functorOS";
      distroId = "functoros";
      vendorName = "functor.systems";
      vendorId = "functorsystems";
      codeName = "Spivak";
    };

    programs.nh = lib.mkIf cfg.useNh {
      enable = true;
      clean = lib.mkIf cfg.nixSaneDefaults {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = config.functorOS.flakeLocation;
    };

    # environment.variables = lib.mkIf (cfg.useNh && config.security.doas.enable) {
    #   NH_FLAKE = config.programs.nh.flake;
    # };

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        icu
        xorg.libXtst
        xorg.libXi
      ];
    };

    boot.tmp.cleanOnBoot = true;

    hardware.enableRedistributableFirmware = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.dconf.enable = true;

    programs.fish.enable = true;

    services.tlp.enable = lib.mkIf (config.functorOS.formFactor == "laptop") true;
    programs.light.enable = lib.mkIf (config.functorOS.formFactor == "laptop") true;

    hardware.bluetooth = lib.mkIf cfg.bluetooth.enable {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = lib.mkIf cfg.bluetooth.enable true;

    services.gvfs.enable = lib.mkIf cfg.useGvfs.enable true;

    warnings =
      if !cfg.suppressWarnings && cfg.useNh && config.functorOS.flakeLocation == "" then
        [
          ''The `nh` CLI is enabled but `functorOS.flakeLocation` is not set. It is recommended that you set this option to the absolute file path of your configuration flake so that `nh` can work without specifying the flake path every time. You can disable this warning by setting `functorOS.system.core.suppressWarnings`.''
        ]
      else
        [ ];

  };
}
