{ config, lib, ... }:

let
  cfg = config.config.profiles.nixos;
in {
  options.config.profiles.nixos.enable = lib.mkEnableOption "nixos integration";

  config = lib.mkIf cfg.enable {
    passthru.systemConfig = (import <nixpkgs/nixos> {}).config;
  };
}
