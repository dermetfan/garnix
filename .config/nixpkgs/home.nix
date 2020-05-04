{ config, lib, pkgs, ... }:

let
  sysCfg = config.passthru.systemConfig or {};
in {
  imports = import home/module-list.nix;

  config = {
    fonts.fontconfig.enable = true;

    home = {
      stateVersion = "19.09";

      packages = with pkgs; [ less ];

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "kak";
        PAGER = "less";
        SHELL = "elvish";
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
        desktop = "/home/dermetfan";
        download = "/home/dermetfan/downloads";
        templates = "/home/dermetfan";
        publicShare = "/home/dermetfan";
        documents = "/data/dermetfan/documents";
        music = "/data/dermetfan/audio/music";
        pictures = "/data/dermetfan/images";
        videos = "/data/dermetfan/videos";
      };
    };
  };
}
