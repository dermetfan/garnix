{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
#      2048-in-terminal
      abcde
      android-studio
      arandr
      audacious
      audacity
      bashmount
      bundix
      chromium
      cool-old-term
      fdupes
      feh
      filezilla
      fortune
      ftop
      fzy
      geany
      gimp
      git
      gnupg
      gpa
      gparted
      gptfdisk
      hdparm
      hipchat
      htop
      i3status
      idea.idea-community
      jq
      kde5.kdenlive
      keymon
      lilyterm
      lmms
      lrzip
      meld
      minecraft
      mplayer
      mpv
      ncdu
      nixui
      nox
      openjdk
      parcellite
      parted
      pass
      peco
      ponysay
      progress
      psmisc
      pv
      mercurial
      networkmanagerapplet
      nitrogen
      qalculate-gtk
      qemu
      rustracer
      rustracerd
      ranger
      rofi
      rogue
      rss-glx
      rsync
      screenfetch
      skype
      sl
      smartmontools
      smplayer
      sshfsFuse
      tdesktop
      xfce.thunar
      tiled
      tor
      unrar
      unzip
      visualvm
      vivaldi
      vlc
      volumeicon
      wakelan
      wget
      xarchiver
      xfce.xfconf
      xfe
      xpdf
      zathura
      zip
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
      ANDROID_HOME = "${pkgs.androidsdk_extras}/libexec";
    };

    file = {
      ".zshrc".source = ./dotfiles/zshrc;
      ".antigenrc".source = ./dotfiles/antigenrc;
      ".hgrc".source = ./dotfiles/hgrc;
      ".xpdfrc".source = ./dotfiles/xpdfrc;
      ".xscreensaver".source = ./dotfiles/xscreensaver;
      ".config/i3/config".source = ../.config/i3/config;
      ".config/i3status/config".source = ../.config/i3status/config;
      ".config/dunst/dunstrc".source = ../.config/dunst/dunstrc;
      ".config/user-dirs.dirs".source = ../.config/user-dirs.dirs;
    };
  };

  programs = {
    git = {
      enable = true;
      userName = "Robin Stumm";
      userEmail = "serverkorken@gmail.com";
      aliases = {
        st = "status -s";
        lg = "log --graph --branches --decorate --abbrev-commit --pretty=medium";
        ci = "commit";
        co = "checkout";
        spull = "__git_spull() { git pull \"$@\" && git submodule sync --recursive && git submodule update --init --recursive; }; __git_spull"; # https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407#.jepjuse2y
      };
      extraConfig = ''
        [status]
        submoduleSummary = true

        [diff]
        submodule = log
      '';
    };

    firefox = {
      enable = true;
      enableAdobeFlash = true;
    };
  };

  services = {
    xscreensaver.enable = true;
    network-manager-applet.enable = true;
    dunst.enable = true;
    udiskie.enable = true;
  };

  gtk = {
    enable = true;
    themeName = "Vertex-Dark";
    iconThemeName = "Numix";
  };
}
