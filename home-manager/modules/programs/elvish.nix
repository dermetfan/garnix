{ config, lib, pkgs, ... }:

let
  cfg = config.programs.elvish;
in {
  options.programs.elvish.enable = lib.mkEnableOption "elvish";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.elvish ];
  };
}
