{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ripgrep;
in {
  options.programs.ripgrep = with lib; {
    enable = mkEnableOption "ripgrep";

    settings = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.ripgrep ];

      sessionVariables.RIPGREP_CONFIG_PATH = config.home.homeDirectory + "/" + config.xdg.configFile."ripgrep".target;
    };

    xdg.configFile."ripgrep".text = cfg.settings;
  };
}
