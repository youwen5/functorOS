{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
in
final: prev: {
  wine-discord-ipc-bridge = callPackage ./by-name/wine-discord-ipc-bridge { };
  functor-systems-icons = callPackage ./by-name/functor-systems-icons { };
}
