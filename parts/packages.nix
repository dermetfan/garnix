{ config, lib, inputs, ... }:

{
  perSystem = { inputs', pkgs, ... }: {
    config = lib.mkIf (config.flake.overlays ? default) {
      packages = inputs.flake-utils.lib.flattenTree (
        lib.getAttrs
        (builtins.attrNames (
          removeAttrs
          (config.flake.overlays.default {} {})
          [ "lib" ]
        ))
        (inputs'.nixpkgs.legacyPackages.extend config.flake.overlays.default)
      );
    };
  };
}
