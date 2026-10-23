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

    (self: super: {
      gnome = super.gnome.overrideScope (
        gself: gsuper: {
          nautilus = gsuper.nautilus.overrideAttrs (nsuper: {
            buildInputs =
              nsuper.buildInputs
              ++ (with super.gst_all_1; [
                gst-plugins-good
                gst-plugins-bad
              ]);
          });
        }
      );
      khal = super.khal.overrideAttrs {
        sphinxBuilders = [ "html man" ];
      };
      wl-kbptr = super.wl-kbptr.overrideAttrs {
        version = "0-unstable-2026-10-23";
        src = super.fetchFromGitHub {
          owner = "moverest";
          repo = "wl-kbptr";
          rev = "6ef84f398816b7a007ba969047e43d095f332175";
          hash = "sha256-nprdHawJqZK0zL0XcHuxmJquDLPKjl1z0rx5cRbkDe0=";
        };
      };
    })
  ];
}
