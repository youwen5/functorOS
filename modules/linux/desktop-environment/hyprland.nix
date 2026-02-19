attrs@{
  hyprland,
  makeWrapper,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = hyprland.pname;
  version = hyprland.version;

  nativeBuildInputs = [ makeWrapper ];

  paths = [
    (hyprland.override attrs)
  ];

  postInstall = ''
    wrapProgram $out/bin/start-hyprland \
      --add-flags "--no-nixgl"
  '';
}
