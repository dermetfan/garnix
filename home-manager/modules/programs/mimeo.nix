{ config, lib, pkgs, ... }:

let
  cfg = config.programs.mimeo;
in {
  options.programs.mimeo = with lib; {
    enable = mkEnableOption "mimeo";
    xdgOpen = mkEnableOption "xdg-open alias";
  };

  config.home.packages = lib.optional cfg.enable (
    with pkgs; 
    if cfg.xdgOpen
    then runCommand "mimeo-xdg-open" {} ''
      mkdir -p $out/bin
      ln -s ${mimeo}/bin/mimeo $out/bin/
      ln -s ${mimeo}/bin/mimeo $out/bin/xdg-open
    ''
    else mimeo
  );
}

