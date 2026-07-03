{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
in
final: prev: {
  wine-discord-ipc-bridge = callPackage ./by-name/wine-discord-ipc-bridge { };
  functor-systems-icons = callPackage ./by-name/functor-systems-icons { };

  # openldap's test017-syncreplication-refresh check is timing-sensitive and
  # routinely fails inside the Nix build sandbox's restricted networking.
  # pkgsi686Linux.openldap is pulled in transitively by FHS environments
  # (e.g. lutris), so a spurious checkPhase failure there breaks unrelated
  # builds; disable checks for that variant only.
  pkgsi686Linux = prev.pkgsi686Linux.extend (
    _final32: prev32: {
      openldap = prev32.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    }
  );
}
