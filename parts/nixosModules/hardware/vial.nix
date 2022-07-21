_:

{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.vial;
in {
  options.hardware.vial.enable = lib.mkEnableOption "Vial udev rules";

  config.services.udev.packages = with pkgs; [ vial-udev-rules ];
}

