{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ranger;
in {
  options.programs.ranger = with lib; {
    enable = mkEnableOption "ranger";

    shell = mkOption {
      type = with types; nullOr str;
      default = config.home.sessionVariables.SHELL or null;
      description = "The shell command to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ranger ];

    xdg.configFile."ranger/rc.conf".text = ''
      ${lib.optionalString (cfg.shell != null) "map S shell ${cfg.shell}"}
    '';
  };
}
