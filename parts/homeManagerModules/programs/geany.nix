{ config, lib, pkgs, ... }:

let
  cfg = config.programs.geany;
in {
  options.programs.geany.enable = lib.mkEnableOption "Geany";

  config.home.packages = lib.optional cfg.enable pkgs.geany;
}
