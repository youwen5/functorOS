{
  pkgs,
  functorOSInputs,
  ...
}:
let
  inherit (pkgs) system;
in
# stablepkgs = inputs.stablepkgs.legacyPackages.${pkgs.system};
{
  nixpkgs.overlays = [
    (import ../pkgs { inherit pkgs; })
    (final: prev: {
      # nix-index-unwrapped = prev.nix-index-unwrapped.overrideAttrs (
      #   finalAttrs: prevAttrs: {
      #     src = functorOSInputs.nix-index;
      #
      #     cargoDeps = prev.rustPlatform.fetchCargoVendor {
      #       inherit (finalAttrs) src;
      #       hash = "sha256-0yrTPrxN/4TOALqpQ5GW7LXKisc8msx3DvEpg8uO+IQ=";
      #     };
      #   }
      # );
      # })
    })
  ];
}
