{ config, lib, ... }:

let
  cfg = config.config.profiles.nixos;
in {
  imports = [ <nixpkgs/nixos/modules/misc/passthru.nix> ];

  options.config.profiles.nixos.enable = lib.mkEnableOption "nixos integration";

  config.passthru = if cfg.enable then {
    systemConfig = (import <nixpkgs/nixos> {}).config;
  } else {};
}
