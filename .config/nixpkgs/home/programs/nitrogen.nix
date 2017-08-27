{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.nitrogen;
in {
  options.config.programs.nitrogen.enable = lib.mkEnableOption "nitrogen";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.nitrogen ];

      file.".config/nitrogen/nitrogen.cfg".text = ''
        [nitrogen]
        view=icon
        recurse=true
        sort=alpha
        icon_caps=false
        dirs=/data/dermetfan/images/wallpapers;
      '';
    };
  };
}
