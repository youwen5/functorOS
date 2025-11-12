{
  lib,
  fetchFromGitHub,
  hyprland,
  pkg-config,
  cmake,
  unstableGitUpdater,
}:
let
  mkHyprlandPlugin =
    hyprland:
    args@{ pluginName, ... }:
    hyprland.stdenv.mkDerivation (
      args
      // {
        pname = "${pluginName}";
        nativeBuildInputs = [ pkg-config ] ++ args.nativeBuildInputs or [ ];
        buildInputs = [ hyprland ] ++ hyprland.buildInputs ++ (args.buildInputs or [ ]);
        meta = args.meta // {
          description = args.meta.description or "";
          longDescription =
            (args.meta.longDescription or "")
            + "\n\nPlugins can be installed via a plugin entry in the Hyprland NixOS or Home Manager options.";
        };
      }
    );
in
mkHyprlandPlugin hyprland {
  pluginName = "hyprscroller";
  version = "0-unstable-2025-11-11";

  src = fetchFromGitHub {
    owner = "cpiber";
    repo = "hyprscroller";
    rev = "a5843b9201dc0728e745310e9f685c797565ba8b";
    hash = "sha256-aAbHgf2Rp2IUospRjdsSFQF5ieeqq8yqJYv76zqD1Pk=";
  };

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv hyprscroller.so $out/lib/libhyprscroller.so

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://github.com/cpiber/hyprscroller";
    description = "Hyprland layout plugin providing a scrolling layout like PaperWM";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ youwen5 ];
    platforms = lib.platforms.linux;
  };
}
