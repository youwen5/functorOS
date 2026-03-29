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
            hash = "sha256-1M8ICkju2M9CNiRoMkeUveINmF7LmeCP0vuu+haJ+kI=";
          };
        }
      );

      # hyprland = prev.stdenv.mkDerivation { inherit (prev.hyprland) pname version; };
    })
  ];
}
