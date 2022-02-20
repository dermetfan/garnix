{ config, lib, pkgs, ... }:

let
  cfg = config.programs.xpdf;
in {
  options.programs.xpdf.enable = lib.mkEnableOption "Xpdf";

  config.home.packages = lib.optional cfg.enable pkgs.xpdf;
}
