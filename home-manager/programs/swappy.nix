{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.swappy;
in {
  options       .programs.swappy.enable = lib.mkEnableOption "swappy";
  options.config.programs.swappy = {
    enable = with lib; mkOption {
      type = types.bool;
      default = config.programs.swappy.enable;
      defaultText = "<option>programs.swappy.enable</option>";
      description = "Whether to configure swappy.";
    };

    config = with lib; mkOption {
      type = with types; attrsOf anything;
      default = {
        Default = mkOptionDefault {
          save_dir = mkOptionDefault config.xdg.userDirs.pictures;
          save_filename_format = mkOptionDefault "swappy-%Y%m%d-%H%M%S.png";
          show_panel = mkOptionDefault true;
          line_size = mkOptionDefault 5;
          text_size = mkOptionDefault 20;
          text_font = mkOptionDefault "sans-serif";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swappy ];

    xdg.configFile."swappy/config".text = lib.generators.toINI {} cfg.config;
  };
}
