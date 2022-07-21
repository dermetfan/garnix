{ config, lib, ... }:

final: prev: {
  lib = prev.lib.extend (final: prev:
    lib.recursiveUpdate prev config.flake.lib
  );
}
