{ config, lib, pkgs, ... }:

let
  systemConfig = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [
      (import <nixos-config> {
        inherit pkgs;
        inherit (pkgs) system lib;
        config = systemConfig.config;
      })
    ];
  }).config;
in {
  imports = import home/module-list.nix;

  home = {
    packages = with pkgs; [
      ranger
      screenfetch
    ] ++ (lib.optional config.services.xscreensaver.enable xscreensaver)
      ++ (lib.optionals config.xsession.enable [
      # X
      arandr
      libnotify
      xorg.xrandr
      xorg.xkill
      xclip
      xsel

      # i3
      i3-gaps
      i3status
      rofi

      # GTK
      theme-vertex
      numix-icon-theme

      # autostart
      udevil
      parcellite
      tdesktop
      hipchat
      nitrogen
      skype
      volumeicon
    ]);

    keyboard = {
      variant = "norman";
      options = [
        "compose:lwin"
        "compose:rwin"
        "eurosign:e"
      ];
    };

    sessionVariableSetter = "pam";
    sessionVariables = {
      SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
    };
  };

  xsession = {
    enable = systemConfig.services.xserver.enable;
    windowManager = "${pkgs.i3-gaps}/bin/i3";
    initExtra = let
      xhost = "${pkgs.xorg.xhost}/bin/xhost";
      xmodmap = "${pkgs.xorg.xmodmap}/bin/xmodmap";
      xflux = "${pkgs.xflux}/bin/xflux";
    in ''
      ${xhost} local:root # allow root to connect to X server for key bindings
      ${xmodmap} -e "keycode 66 = Caps_Lock"
      ${xflux} -l 51.165691 -g 10.45152000000058
      xset r rate 225 27
      xset m 2
      devmon &
      syndaemon -d -i 0.625 -K -R || :

      ~/.fehbg || nitrogen --restore
      volumeicon &
      parcellite &
      telegram-desktop &
      hipchat &
      skype &
    '';
  };

  programs = {
    home-manager.enable = true;

    browserpass = {
      enable = true;
      browsers = [
        "vivaldi"
        "chromium"
        "firefox"
      ];
    };

    beets.settings = let
      dir = let
        data = /data/dermetfan;
      in "${if builtins.pathExists data then builtins.toString data else "~"}/audio/music/library";
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

    git = {
      enable = true;
      userName = "Robin Stumm";
      userEmail = "serverkorken@gmail.com";
      aliases = {
        st = "status -s";
        lg = "log --graph --branches --decorate --abbrev-commit --pretty=medium";
        co = "checkout";
        ci = "commit";
        spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
      };
      extraConfig = ''
        [status]
        submoduleSummary = true

        [diff]
        submodule = log
      '';
    };

    firefox = {
      enable = config.xsession.enable;
      enableAdobeFlash = true;
    };
  };

  services = {
    dunst.enable = config.xsession.enable;
    network-manager-applet.enable = config.xsession.enable;
    xscreensaver.enable = config.xsession.enable;
  };

  gtk = {
    enable = config.xsession.enable;
    themeName = "Vertex-Dark";
    iconThemeName = "Numix";
  };
}
