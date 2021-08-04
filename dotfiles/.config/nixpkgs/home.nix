{ config, lib, pkgs, ... }:

let
  sysCfg = config.passthru.systemConfig or {};
in {
  imports = import home/module-list.nix;

  config = {
    fonts.fontconfig.enable = true;

    home = {
      stateVersion = "20.09";
      username = sysCfg.users.users.dermetfan.name;
      homeDirectory = sysCfg.users.users.dermetfan.home;

      keyboard = {
        layout = "us,ru";
        variant = "norman,phonetic";
      };

      packages = with pkgs; [ less ];

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "kak";
        PAGER = "less";
        LESS = "-RiW -#.05 -n4 -z-3";
      };
    };

    services.syncthing.enable = true;

    programs = {
      home-manager.enable = true;

      ranger.enable = true;
      broot.enable = true;
      htop.enable = true;
      micro.enable = true;
      kakoune.enable = true;
      nano.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      fish.enable = true;
      elvish.enable = true;

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
    };

    systemd.user.startServices = true;

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        desktop = config.home.homeDirectory;
        download = "${config.home.homeDirectory}/downloads";
        templates = config.home.homeDirectory;
        publicShare = config.home.homeDirectory;
        documents = "/data/${config.home.username}/documents";
        music = "/data/${config.home.username}/audio/music";
        pictures = "/data/${config.home.username}/images";
        videos = "/data/${config.home.username}/videos";
      };
    };
  };
}
