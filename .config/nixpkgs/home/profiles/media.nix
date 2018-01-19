{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.media;
in {
  options.config.profiles.media = with lib; {
    enable = mkEnableOption "media viewers";
    enableEditors = mkEnableOption "media editing programs";
  };

  config = lib.mkIf cfg.enable {
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
          lmms
          gimp
          inkscape
          keymon
          obs-studio
        ]);
  };
}
