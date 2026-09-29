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

    programs.firefox = {
      languagePacks = [ "de" ];

      policies.NoDefaultBookmarks = true;

      nativeMessagingHosts = with pkgs; [
        gopass-jsonapi
      ];

      profiles.${config.home.username} = {
        search = {
          default = "ecosia";
          engines = {
            ecosia.metaData = {};
            google.metaData = {};
          };
          order = [ "ecosia" "google" ];
          force = true;
        };

        settings."widget.use-xdg-desktop-portal.file-picker" = assert config.services.xdg-desktop-portal-termfilepickers.enable; 1;

        extensions = {
          packages = with nur.repos.rycee.firefox-addons; [
            auto-reject-cookies
            auto-tab-discard
            gopass-bridge
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
    };
  };
}
