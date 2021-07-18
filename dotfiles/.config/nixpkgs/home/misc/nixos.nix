{ config, lib, nixosConfig ? null, ... }:

let
  cfg = config.nixos;
in {
  imports = [ <nixpkgs/nixos/modules/misc/passthru.nix> ];

  options.nixos.enable = lib.mkEnableOption "nixos integration";

  # XXX Is it be possible to replace the nixosConfig specialArg? (clues may be found in <home-manager/nixos>)
  config.passthru = if cfg.enable then {
    systemConfig = if nixosConfig != null then nixosConfig else
      (import <nixpkgs/nixos> {}).config;
  } else {};
}
