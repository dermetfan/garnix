{ config, lib, pkgs, ... }:

let
  cfg = config.programs.micro;
in {
  options.programs.micro.enable = lib.mkEnableOption "micro";

  config.home.packages = with pkgs; lib.optionals cfg.enable [
    micro
    mkinfo
  ];
}
