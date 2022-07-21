{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swappy;
in {
  options.programs.swappy = with lib; {
    enable = mkEnableOption "swappy";

    settings = mkOption {
      type = with types; attrsOf anything;
      default.Default = mkOptionDefault (builtins.mapAttrs (k: mkOptionDefault) {
        save_dir = config.xdg.userDirs.pictures;
        save_filename_format = "swappy-%Y%m%d-%H%M%S.png";
        show_panel = true;
        line_size = 5;
        text_size = 20;
        text_font = "sans-serif";
      });
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swappy ];

    xdg.configFile."swappy/config".text = lib.generators.toINI {} cfg.settings;
  };
}
