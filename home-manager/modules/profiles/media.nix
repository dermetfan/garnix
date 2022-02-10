{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.media;
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
        # TODO make it possible upstream for `library` to refer to `config.programs.beets.settings.directory`
        settings = rec {
          directory =
            builtins.replaceStrings [ "$HOME/" ] [ "${config.home.homeDirectory}/" ]
              config.xdg.userDirs.music +
            "/library";
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
