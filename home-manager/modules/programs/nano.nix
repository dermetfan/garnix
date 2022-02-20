{ config, lib, pkgs, ... }:

let
  cfg = config.programs.nano;
in {
  options.programs.nano.enable = lib.mkEnableOption "nano";

  config.home.packages = lib.optional cfg.enable pkgs.nano;
}
