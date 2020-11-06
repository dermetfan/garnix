{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.media;
  sysCfg = config.passthru.systemConfig or null;
in {
  options.profiles.media = with lib; {
    enable = mkEnableOption "media viewers";
    enableEditors = mkEnableOption "media editing programs";
    enableStudios = mkEnableOption "media creation studios";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      beets = {
        enable = builtins.any (x: x == pkgs.stdenv.system) pkgs.beets.meta.platforms;
        settings = rec {
          directory = (
            if sysCfg.config.data.enable or false
            then sysCfg.config.data.mountPoint +
              (lib.optionalString sysCfg.config.data.userFileSystems "/${config.home.username}")
            else "~"
          ) + "/audio/music/library";
          library = "${directory}/beets.db";
          plugins = [
            "fromfilename"
            "discogs"
            "duplicates"
            "edit"
            "fetchart"
            "ftintitle"
            "fuzzy"
            "info"
            "lastgenre"
            "lyrics"
            "mbsubmit"
            "mbsync"
            "missing"
            "play"
            "random"
            "web"
          ];
          play = {
            command = "audacious";
            raw = true;
          };
        };
      };

      obs-studio.enable = cfg.enableStudios && config.profiles.gui.enable;
      feh.enable = config.profiles.gui.enable;
    };

    home.packages = with pkgs;
      [ abcde
        mplayer
        mpv
      ] ++
      lib.optionals config.profiles.gui.enable [
        audacious
        smplayer
      ] ++
      lib.optionals cfg.enableEditors (
        [ ffmpeg
          kid3
        ] ++
        lib.optionals config.profiles.gui.enable [
          audacity
          gimp
          inkscape
        ]
      ) ++
      lib.optionals (cfg.enableStudios && config.profiles.gui.enable) [
        lmms

        # utils
        keymon
      ]
    ;
  };
}
