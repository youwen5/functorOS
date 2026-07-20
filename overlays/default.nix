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
          inherit (functorOSInputs.nix-index.packages.${pkgs.stdenv.hostPlatform.system}.default)
            src
            version
            ;

          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) src;
            hash = "sha256-5dc7AazqAnI0wwLTUS5slAP45cwJQMSVRYg6SBlnOao=";
          };
        }
      );
    })
  ];
}
