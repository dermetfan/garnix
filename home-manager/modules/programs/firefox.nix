{ nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.programs.firefox;
in {
  options.programs.firefox = with lib; {
    background = mkOption {
      type = types.str;
      default = "#434a52";
    };

    hideTabs = mkEnableOption "hide tabs";
  };

  config = {
    programs.firefox = {
      package = lib.mkIf (!config.xsession.enable && !nixosConfig.services.xserver.enable or false) pkgs.firefox-wayland;

      profiles.${config.home.username}.userChrome = lib.optionalString cfg.hideTabs ''
        /** Hide horizontal tabs at the top of the window
         * https://github.com/piroor/treestyletab/wiki/Code-snippets-for-custom-style-rules#hide-horizontal-tabs-at-the-top-of-the-window-1349-1672-2147 */
        #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
          opacity: 0;
          pointer-events: none;
        }
        #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
            visibility: collapse !important;
        }
      '';
    };

    home.file.".mozilla/firefox/${config.programs.firefox.profiles.${config.home.username}.path}/chrome/userContent.css".text = lib.mkIf cfg.enable ''
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
