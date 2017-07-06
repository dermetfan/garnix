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
  imports = import ./home;

  home = {
    packages = with pkgs; [
      bashmount
      exa
      gnupg
      nethogs
      ranger
      screenfetch
      unrar
      unzip
      zip
    ] ++ (if config.services.xscreensaver.enable then with pkgs; [
      xscreensaver
    ] else []) ++ (if config.xsession.enable then with pkgs; [
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

      # autostart
      parcellite
      tdesktop
      hipchat
      nitrogen
      skype
      volumeicon
    ] else []);

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

    file = builtins.concatLists (builtins.map (path:
      let
        x = import path;
        listify = y: if builtins.isList y then y else [ y ];
      in listify (if builtins.isFunction x then
        let
          value = pkgs.callPackage path { inherit systemConfig; };
        in if builtins.isList value then value else
          (builtins.removeAttrs value [ "override" "overrideDerivation" ])
      else x)
    ) [
      home/file/antigen.nix
      home/file/cargo.nix
      home/file/minecraft.nix
      home/file/hg.nix
      home/file/xpdf.nix
      home/file/xscreensaver.nix
      home/file/zsh.nix
      home/file/i3.nix
      home/file/i3status.nix
      home/file/ranger.nix
      home/file/rofi.nix
      home/file/nitrogen.nix
      home/file/lilyterm.nix
      home/file/dunst.nix
      home/file/volumeicon.nix
      home/file/parcellite.nix
      home/file/htop.nix
      home/file/nano.nix
      home/file/geany.nix
      home/file/xfe.nix
      home/file/user-dirs.nix
    ]);
  };

  xsession = {
    enable = systemConfig.services.xserver.enable;
    windowManager = "${pkgs.i3-gaps}/bin/i3";
    initExtra = let
      xhost = "${pkgs.xorg.xhost}/bin/xhost";
      xmodmap = "${pkgs.xorg.xmodmap}/bin/xmodmap";
      xflux = "${pkgs.xflux}/bin/xflux";
      devmon = "${pkgs.udevil}/bin/devmon";
    in ''
      ${xhost} local:root # allow root to connect to X server for key bindings
      ${xmodmap} -e "keycode 66 = Caps_Lock"
      ${xflux} -l 51.165691 -g 10.45152000000058
      xset r rate 225 27
      xset m 2
      ${devmon} &
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
      import.move = true;
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
