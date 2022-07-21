_:

{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.uhk;
in {
  options.hardware.uhk.enable = lib.mkEnableOption "UHK udev rules";

  config.services.udev.packages = with pkgs; [ uhk-udev-rules ];
}
