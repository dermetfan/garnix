{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.nitrogen;
in {
  options       .programs.nitrogen.enable = lib.mkEnableOption "nitrogen";
  options.config.programs.nitrogen.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.nitrogen.enable;
    defaultText = "<option>config.programs.nitrogen.enable</option>";
    description = "Whether to configure nitrogen.";
  };

  config.home.packages = lib.optional config.programs.nitrogen.enable pkgs.nitrogen;
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
