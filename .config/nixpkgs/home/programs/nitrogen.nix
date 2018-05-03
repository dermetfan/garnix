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
  config.home.file = lib.mkIf cfg.enable {
    ".config/nitrogen/nitrogen.cfg".text = ''
      [nitrogen]
      view=icon
      recurse=true
      sort=alpha
      icon_caps=false
      dirs=/data/dermetfan/images/wallpapers;
    '';
  };
}
