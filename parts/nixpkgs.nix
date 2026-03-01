{ config, lib, ... }:

{
  perSystem = { inputs', ... }: {
    _module.args.pkgs = inputs'.nixpkgs.legacyPackages.appendOverlays (
      lib.optional (config.flake.overlays ? small)
        config.flake.overlays.small
    );
  };
}
