{ self, nixosConfig, config, lib, ... }:

{
  imports = [ self.outputs.homeManagerModule ];

  home = {
    keyboard = {
      layout = "us,ru";
      variant = "norman,phonetic";
    };

    sessionVariables = {
      TERMINAL = "alacritty";
      EDITOR = "kak";
      PAGER = "less";
      LESS = "-RiW -#.05 -n4 -z-3";
    };
  };

  programs = {
    alacritty.enable = true;
    ranger.enable = true;
    broot.enable = true;
    htop.enable = true;
    micro.enable = true;
    kakoune.enable = true;
    nano.enable = true;
    tmux.enable = true;
    fish.enable = true;

    browserpass = {
      enable = lib.mkDefault (
        config.programs.firefox.enable ||
        config.programs.chromium.enable
      );
      browsers = [
        "vivaldi"
        "chromium"
        "firefox"
      ];
    };

    mimeo = {
      enable = true;
      xdgOpen = true;
    };
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "kakoune.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };

    userDirs = {
      download  = "$HOME/downloads";
      documents = "$HOME/documents";
      music     = "$HOME/audio/music";
      pictures  = "$HOME/images";
      videos    = "$HOME/videos";
    };
  };
}
