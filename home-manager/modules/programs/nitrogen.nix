{ config, lib, pkgs, ... }:

let
  cfg = config.programs.nitrogen;
in {
  options.programs.nitrogen.enable = lib.mkEnableOption "nitrogen";

  config.home.packages = lib.optional cfg.enable pkgs.nitrogen;
}
