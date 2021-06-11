{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.swappy;
in {
  options       .programs.swappy.enable = lib.mkEnableOption "swappy";
  options.config.programs.swappy.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.swappy.enable;
    defaultText = "<option>programs.swappy.enable</option>";
    description = "Whether to configure swappy.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swappy ];

    xdg.configFile."swappy/config".text = lib.generators.toINI {} {
      Default = {
        save_dir = config.xdg.userDirs.pictures;
        save_filename_format = "swappy-%Y%m%d-%H%M%S.png";
        show_panel = true;
        line_size = 5;
        text_size = 20;
        text_font = "sans-serif";
      };
    };
  };
}
