{ config, lib, pkgs, ... }:

let
  cfg = config.programs.volumeicon;
in {
  options.programs.volumeicon = with lib; {
    enable = mkEnableOption "volumeicon";

    settings = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.volumeicon ];

    xdg.configFile."volumeicon/volumeicon".text = cfg.settings;
  };
}
