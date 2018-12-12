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
    programs.beets = lib.mkIf (builtins.any (x: x == pkgs.stdenv.system) pkgs.beets.meta.platforms) {
      settings = let
        dir = (
          if sysCfg.config.data.enable or false
          then sysCfg.config.data.mountPoint +
            (lib.optionalString sysCfg.config.data.userFileSystems "/${sysCfg.users.users.dermetfan.name}")
          else "~"
        ) + "/audio/music/library";
      in {
        directory = dir;
        library = "${dir}/beets.db";
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

    home.packages = with pkgs;
      [ abcde
        mplayer
        mpv
      ] ++
      lib.optionals config.xsession.enable [
        audacious
        feh
        smplayer
      ] ++
      lib.optionals cfg.enableEditors (
        [ ffmpeg
          kid3
        ] ++
        lib.optionals config.xsession.enable [
          audacity
          gimp
          inkscape
        ]
      ) ++
      lib.optionals (cfg.enableStudios && config.xsession.enable) [
        lmms
        obs-studio

        # utils
        keymon
      ]
    ;
  };
}
