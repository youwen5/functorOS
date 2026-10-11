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
  ];
}
