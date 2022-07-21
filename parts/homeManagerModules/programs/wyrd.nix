{ config, lib, pkgs, ... }:

let
  cfg = config.programs.wyrd;
in {
  options.programs.wyrd.enable = lib.mkEnableOption "wyrd";

  config.home.packages = with pkgs; lib.optionals cfg.enable [ wyrd remind ];
}

