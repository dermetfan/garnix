{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.starship;
in {
  options.profiles.dermetfan.programs.starship.enable = lib.mkEnableOption "starship" // {
    default = config.programs.starship.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.powerline-fonts ];

    programs.starship.settings = {
      add_newline = false;
      line_break.disabled = true;
      cmd_duration.disabled = true;
    };
  };
}
