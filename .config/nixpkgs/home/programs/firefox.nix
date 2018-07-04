{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.firefox;
in {
  options.config.programs.firefox = {
    enable = with lib; mkOption {
      type = types.bool;
      default = config.programs.firefox.enable;
      defaultText = "<option>config.programs.firefox.enable</option>";
      description = "Whether to configure Firefox.";
    };

    background = with lib; mkOption {
      type = types.str;
      default = "#434a52";
    };
  };

  config.home.file = lib.mkIf cfg.enable {
    ".mozilla/firefox/profiles.ini".text = ''
      [General]
      StartWithLastProfile=1

      [Profile0]
      Name=default
      IsRelative=1
      Path=dermetfan.default
      Default=1
    '';

    ".mozilla/firefox/dermetfan.default/chrome/userContent.css".text = ''
      @-moz-document
      url('about:newtab'),
      url('about:blank') {
          body {
              background: ${cfg.background} !important;
          }
      }
    '';
  };
}
