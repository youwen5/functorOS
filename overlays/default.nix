{
  pkgs,
  functorOSInputs,
  ...
}:
let
  # bleedingpkgs = inputs.bleedingpkgs.legacyPackages.${pkgs.system};
  inherit (pkgs) system;
in
# stablepkgs = inputs.stablepkgs.legacyPackages.${pkgs.system};
# nixpkgs-small = inputs.nixpkgs-unstable-small.legacyPackages.${pkgs.system};
{
  nixpkgs.overlays = [
    (import ../pkgs { inherit pkgs; })
    (final: prev: {
      nix-index-unwrapped = prev.nix-index-unwrapped.overrideAttrs (
        finalAttrs: prevAttrs: {
          src = functorOSInputs.nix-index;

          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) src;
            hash = "sha256-0yrTPrxN/4TOALqpQ5GW7LXKisc8msx3DvEpg8uO+IQ=";
          };
        }
      );
      hyprutils = prev.hyprutils.overrideAttrs (finalAttrs: {
        version = "0.10.0";
        src = prev.fetchFromGitHub {
          owner = "hyprwm";
          repo = "hyprutils";
          tag = "v${finalAttrs.version}";
          hash = "sha256-FWB9Xe9iIMlUskfLzKlYH3scvnHpSC5rMyN1EDHUQmE=";
        };
      });
    })
  ];
}
