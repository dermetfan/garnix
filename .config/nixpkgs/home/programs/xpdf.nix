{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.xpdf;
in {
  options.config.programs.xpdf.enable = lib.mkEnableOption "xpdf";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.xpdf ];

      file.".xpdfrc".text = ''
        continuousView yes
        initialZoom width
      '';
    };
  };
}
