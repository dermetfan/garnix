{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.alacritty;
in {
  options.config.programs.alacritty.enable = lib.mkEnableOption "alacritty";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.alacritty ];

      file.".config/alacritty/alacritty.yml".text = ''
        visual_bell:
          animation: EaseOutSine
          duration: 100
        background_opacity: 0.7
      '';
    };
  };
}
