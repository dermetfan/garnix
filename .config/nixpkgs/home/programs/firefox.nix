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

    hideTabs = lib.mkEnableOption "hide tabs";
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

    ".mozilla/firefox/dermetfan.default/chrome/userChrome.css".text = ''
      /**
       * @name Dim Unloaded Tabs
       * @author Niklas Gollenstede
       * @licence CC-BY-SA-4.0 or MIT or MPL 2.0
       * @description
       *     This style dims not loaded tabs in Firefox.
       *     It is complementary to the UnloadTabs WebExtension and can either:
       *     * be manually added to the `chrome/user.chrome.css` file in Firefox's profile directory
       *     * or installed with the reStyle Firefox extension (and NativeExt).
       *
       *     If you have any issues with this style, please open a ticket at https://github.com/NiklasGollenstede/unload-tabs
       */

      @-moz-document
          url(chrome://browser/content/browser.xul)
      {
          tab[pending], #alltabs-popup menuitem[pending]
          {
              opacity: 0.6 !important;
          }
      }
    '' + lib.optionalString cfg.hideTabs ''
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
