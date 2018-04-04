{ config, lib, utils, pkgs, ... }:

let
  sysCfg = config.passthru.systemConfig or {};
in {
  imports = import home/module-list.nix ++ [
    <nixpkgs/nixos/modules/misc/extra-arguments.nix>
    <nixpkgs/nixos/modules/misc/passthru.nix>
  ];

  config = {
    config = {
      profiles = {
        desktop.enable = config.xsession.enable;
      };

      programs = {
        ranger.enable = true;
        htop  .enable = true;
        micro .enable = true;
        nano  .enable = true;

        parcellite  .enable = config.xsession.enable;
        volumeicon  .enable = config.xsession.enable;
        xscreensaver.enable = config.xsession.enable;
      };
    };

    home = {
      packages = with pkgs;
        [ less ] ++
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

          # autostart
          xorg.xmodmap
          xflux
          udevil
          tdesktop
          hipchat
          nitrogen
          skype
        ];

      keyboard = {
        variant = "norman";
        options = [
          "compose:lwin"
          "compose:rwin"
          "eurosign:e"
        ];
      };

      sessionVariableSetter =
        if with utils; toShellPath sysCfg.users.users.dermetfan.shell or null == toShellPath pkgs.zsh
        then "zsh"
        else "pam";
      sessionVariables = {
        EDITOR = "micro";
        PAGER = "less";
        SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      };
    };

    xsession = {
      enable = sysCfg.services.xserver.enable or false;
      windowManager.command = "${pkgs.i3-gaps}/bin/i3";
      initExtra = ''
        xmodmap -e "keycode 66 = Caps_Lock"
        xflux -l 51.165691 -g 10.45152000000058
        xset r rate 225 27
        xset m 5 1
        devmon &
        syndaemon -d -i 0.625 -K -R || :

        ~/.fehbg || nitrogen --restore
        volumeicon &
        parcellite &
        telegram-desktop &
        hipchat &
        skypeforlinux &
      '';
    };

    programs = {
      home-manager = {
        enable = true;
        path = "${pkgs.home-manager-src}";
      };

      zsh = {
        enable = true;
        shellAliases = {
          l = "exa -lga";
          ll = "exa -lg";
          less = "less -R";
          diff = "diff -r --suppress-common-lines";
          grep = "grep --color=auto";
          d = "dirs -v | head -10";
          pu = "pushd";
          po = "popd";
          watch = "watch --color";
        };
        initExtra = ''
          setopt AUTO_CD
          setopt AUTO_PUSHD
          setopt AUTO_MENU
          setopt COMPLETE_ALIASES
          setopt COMPLETE_IN_WORD
          setopt ALWAYS_TO_END
          setopt EXTENDED_HISTORY
          setopt HIST_EXPIRE_DUPS_FIRST
          setopt HIST_IGNORE_ALL_DUPS
          setopt HIST_IGNORE_SPACE
          setopt HIST_VERIFY
          setopt APPEND_HISTORY
          setopt INC_APPEND_HISTORY
          setopt PUSHD_IGNORE_DUPS

          zstyle ':completion:*' menu select
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

          ######################################### oh-my-zsh/lib/key-bindings.zsh #########################################
          # start typing + [Up-Arrow] - fuzzy find history forward
          if [[ "''${terminfo[kcuu1]}" != "" ]]; then
            autoload -U up-line-or-beginning-search
            zle -N up-line-or-beginning-search
            bindkey "''${terminfo[kcuu1]}" up-line-or-beginning-search
          fi
          # start typing + [Down-Arrow] - fuzzy find history backward
          if [[ "''${terminfo[kcud1]}" != "" ]]; then
            autoload -U down-line-or-beginning-search
            zle -N down-line-or-beginning-search
            bindkey "''${terminfo[kcud1]}" down-line-or-beginning-search
          fi

          bindkey '^[[1;5C' forward-word                          # [Ctrl-RightArrow] - move forward one word
          bindkey '^[[1;5D' backward-word                         # [Ctrl-LeftArrow] - move backward one word

          if [[ "''${terminfo[kcbt]}" != "" ]]; then
            bindkey "''${terminfo[kcbt]}" reverse-menu-complete   # [Shift-Tab] - move through the completion menu backwards
          fi
          ##################################################################################################################

          typeset -U PATH path
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

      beets = lib.mkIf (builtins.any (x: x == pkgs.stdenv.system) pkgs.beets.meta.platforms) {
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

      git = {
        enable = true;
        userName = "Robin Stumm";
        userEmail = "serverkorken@gmail.com";
        aliases = {
          st = "status -s";
          lg = "log --graph --branches --decorate --abbrev-commit --pretty=medium HEAD";
          co = "checkout";
          ci = "commit";
          spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
        };
        extraConfig = {
          status.submoduleSummary = true;
          diff.submodule = "log";
        };
      };
    };

    services = {
      blueman-applet.enable         = config.xsession.enable && sysCfg.hardware.bluetooth.enable or true;
      dunst.enable                  = config.xsession.enable;
      network-manager-applet.enable = config.xsession.enable;
      xscreensaver.enable           = config.xsession.enable;
    };

    gtk = {
      enable = config.xsession.enable;
      theme = {
        name = "Vertex-Dark";
        package = pkgs.theme-vertex;
      };
      iconTheme = {
        name = "Numix";
        package = pkgs.numix-icon-theme;
      };
    };
  };
}
