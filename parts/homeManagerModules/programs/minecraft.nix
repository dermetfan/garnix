{ config, lib, pkgs, ... }:

let
  cfg = config.programs.minecraft;
in {
  options.programs.minecraft.enable = lib.mkEnableOption "Minecraft";

  config.home.packages = lib.optional cfg.enable pkgs.minecraft;
}
