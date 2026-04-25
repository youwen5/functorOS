{
  pkgs,
  functorOSInputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
# stablepkgs = inputs.stablepkgs.legacyPackages.${pkgs.system};
{
  nixpkgs.overlays = [
    (import ../pkgs { inherit pkgs; })
    (final: prev: {
      nix-index-unwrapped = prev.nix-index-unwrapped.overrideAttrs (
        finalAttrs: prevAttrs: {
          src = functorOSInputs.nix-index;

          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) src;
            hash = "sha256-2Ar7mj9r5eKdbXDC4+jSWG7HvGFTeowEPt2SBM6a6e4=";
          };
        }
      );

      # hyprland = prev.stdenv.mkDerivation { inherit (prev.hyprland) pname version; };
    })
  ];
}
