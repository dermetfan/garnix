parts @ { lib, ... }:

lib.composeManyExtensions (map (file: import file parts) [
  ./rnav.nix
  ./starfighter.nix
])
