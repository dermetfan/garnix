{ config, lib, pkgs, ... }:

let
  systemModule = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [
      (import <nixos-config> {
        inherit pkgs;
        inherit (pkgs) system lib;
        config = systemModule.config;
      })
    ];
  });

  systemConfig = systemModule.config;
in {
  imports = import home/modules/module-list.nix ++ [
    <nixpkgs/nixos/modules/misc/passthru.nix>
  ];

  passthru = {
    inherit systemConfig;

    programs.zsh.shellAliases = {
      l = "exa -lga";
      ll = "exa -lg";
      diff = "diff -r --suppress-common-lines";
    };
  };

  home = {
    packages = with pkgs;
      [ ranger ] ++
      lib.optionals config.programs.zsh.enable [
        exa
        diffutils
      ] ++
      lib.optional config.services.xscreensaver.enable xscreensaver ++
      lib.optionals config.xsession.enable [
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
        xorg.xmodmap
        xflux
        udevil
        parcellite
        tdesktop
        hipchat
        nitrogen
        skype
        volumeicon
      ];

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
    initExtra = ''
      xmodmap -e "keycode 66 = Caps_Lock"
      xflux -l 51.165691 -g 10.45152000000058
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
    home-manager = {
      enable = true;
      modulesPath = "$HOME/.config/nixpkgs/overlays/home-manager/home-manager/modules";
    };

    zsh = {
      enable = true;
      shellAliases = lib.mkIf
        (!config.home.file ? ".antigenrc")
        config.passthru.programs.zsh.shellAliases;
      initExtra = ''
        # include Cargo binaries in PATH
        typeset -U path
        path+=(~/.cargo/bin)
        export PATH
      '';
    };

    browserpass = {
      enable = true;
      browsers = [
        "vivaldi"
        "chromium"
        "firefox"
      ];
    };

    beets.settings = let
      dir = (if systemConfig.config.dataPool.enable then
        systemConfig.config.dataPool.mountPoint + (lib.optionalString systemConfig.config.dataPool.userFileSystems "/${systemConfig.users.users.dermetfan.name}")
      else "~") + "/audio/music/library";
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
