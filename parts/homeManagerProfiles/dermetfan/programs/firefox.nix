{ self, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.firefox;
  inherit (pkgs.extend self.inputs.nur.overlays.default) nur;
in {
  options.profiles.dermetfan.programs.firefox.enable = lib.mkEnableOption "firefox" // {
    default = config.programs.firefox.enable;
  };

  config = {
    stylix.targets.firefox = {
      colorTheme.enable = true;
      profileNames = [ config.home.username ];
    };

    programs = {
      firefox.profiles.${config.home.username} = {
        settings."widget.use-xdg-desktop-portal.file-picker" = assert config.services.xdg-desktop-portal-termfilepickers.enable; 1;

        userChrome = ''
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
        '';

        extensions = {
          packages = with nur.repos.rycee.firefox-addons; [
            auto-reject-cookies
            auto-tab-discard
            browserpass
            cookies-txt
            darkreader
            decentraleyes
            disconnect
            export-tabs-urls-and-titles
            multi-account-containers
            read-aloud
            text-contrast-for-dark-themes
            ublock-origin
            uppity
            youtube-recommended-videos
          ];

          # needed by stylix
          force = true;
        };
      };

      browserpass.enable = true;
    };
  };
}
