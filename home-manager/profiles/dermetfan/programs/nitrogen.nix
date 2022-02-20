{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.nitrogen;
in {
  options.profiles.dermetfan.programs.nitrogen.enable = lib.mkEnableOption "nitrogen" // {
    default = config.programs.nitrogen.enable or false;
  };

  config.xdg.configFile = lib.mkIf cfg.enable {
    "nitrogen/nitrogen.cfg".text = ''
      [nitrogen]
      view=icon
      recurse=true
      sort=alpha
      icon_caps=false
      dirs=${config.xdg.userDirs.pictures}/wallpapers;
    '';
  };
}
