{ config, lib, pkgs, ... }:

let
  cfg = config.programs.timewarrior;
in {
  options.programs.timewarrior.enable = lib.mkEnableOption "timewarrior";

  config.home.packages = lib.optional cfg.enable pkgs.timewarrior;
}
