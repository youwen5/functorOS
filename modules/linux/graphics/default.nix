{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.functorOS.system.graphics;
in
{
  options.functorOS.system.graphics = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to set up basic graphics settings and options.
      '';
    };
    nvidia = {
      enable = lib.mkEnableOption "recommended nvidia drivers and configuration";
      cuda.enable = lib.mkEnableOption "cuda";
      optimus-prime.enable = lib.mkEnableOption "Nvidia OPTIMUS and PRIME";
      optimus-prime.powerMode = lib.mkOption {
        type = lib.types.enum [
          "powersaving"
          "performance"
        ];
        default = "performance";
        description = ''
          Whether to use Nvidia OPTIMUS with maximum performance using the discrete graphics card, or to use offload mode to primarily use the integrated GPU and save power.
        '';
      };
      suppressUnfreeWarning = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to disable the assertion that warns the user if they try to enable proprietary nvidia drivers without setting allowUnfree.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion =
            !cfg.nvidia.enable
            || (config.functorOS.config.allowUnfree && cfg.nvidia.enable)
            || cfg.nvidia.suppressUnfreeWarning;
          message = "You enabled Nvidia proprietary driver installation but did not allow unfree packages to be installed! Consider setting functorOS.config.allowUnfree = true or nixpkgs.config.allowUnfree = true. If you are using an allowUnfreePredicate to whitelist these packages manually, you can set functorOS.system.graphics.nvidia.suppressUnfreeWarning = true";
        }
      ];
    }
    (lib.mkIf cfg.enable {
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          libva-vdpau-driver
        ];
      };

      services.xserver.videoDrivers = lib.mkIf cfg.nvidia.enable [ "nvidia" ];
    })
    (lib.mkIf cfg.nvidia.enable {
      hardware.nvidia = lib.mkIf cfg.nvidia.enable {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = true;
        package =
          if (lib.versionAtLeast config.boot.kernelPackages.nvidiaPackages.latest.version "590.44.01") then
            config.boot.kernelPackages.nvidiaPackages.latest
          else
            config.boot.kernelPackages.nvidiaPackages.beta;
        nvidiaSettings = true;
      };

      functorOS.config.extraUnfreePackages = [
        "nvidia-x11"
        "nvidia-settings"
      ];
    })
    (lib.mkIf cfg.nvidia.cuda.enable {
      nixpkgs.config.cudaSupport = true;
      nix.settings = {
        substituters = [ "https://cache.nixos-cuda.org/" ];
        trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
      };

      # Allow every NVIDIA CUDA-ecosystem license (CUDA, cuDNN, TensorRT, ...).
      # This must match cache.nixos-cuda.org (built with allowUnfree): e.g. onnxruntime
      # only enables TensorRT when it is "available", which otherwise changes its hash.
      functorOS.config.extraUnfreeLicenses =
        with lib.licenses;
        map (l: l.shortName) [
          nvidiaCuda
          nvidiaCudaRedist
          nvidiaCudaPython
          nvidiaCudnn
          nvidiaCuptiPython
          nvidiaCusparse_lt
          nvidiaCutensor
          nvidiaCutlassDsl
          nvidiaMath_sdk_sla
          nvidiaTensorrt
        ];
    })
  ];
}
