{ nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.zsh;
in {
  options.profiles.dermetfan.programs.zsh.enable = lib.mkEnableOption "zsh" // {
    default = config.programs.zsh.enable;
  };

  config = {
    home.packages = with pkgs; [
      diffutils
    ];

    programs = {
      eza.enable = true;
      zoxide.enable = true;

      zsh = {
        enableAutosuggestions = true;
        enableCompletion = let
          sysZshCfg = nixosConfig.programs.zsh or (
            builtins.trace
              ''
                It is unknown whether zsh completion is loaded on startup.
                Not loading it to avoid doing so twice by mistake.
                You may get an error on zsh startup about `compdef` not being found.
                Add `programs.zsh.enableCompletion = lib.mkForce true` to your `~/.config/nixpkgs/home/profiles/local.nix` if needed.
              ''
              {
                enable = true;
                enableCompletion = true;
              }
          );
        in !sysZshCfg.enable || !sysZshCfg.enableCompletion;

        history.share = false;

        shellAliases = {
          diff = "diff -r --suppress-common-lines";
          grep = "grep --color=auto";
          d = "dirs -v | head -10";
          pu = "pushd";
          po = "popd";
          watch = "watch --color";
          pv = "pv -pea";
        };

        autocd = true;

        sessionVariables.WORDCHARS = "";

        initExtra = ''
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
          ##################################################################################################################

          typeset -U PATH path

          eval "$(zoxide init zsh)"

          function sudof {
              sudo zsh -c "`declare -f $1`; `echo $@`"
          }

          function zfs {
              case "$1" in
                  tags) zfs get -Ht snapshot userrefs | grep -v $'\t'0 | cut -d $'\t' -f 1 | tr '\n' '\0' | xargs -0 zfs holds ;;
                  *) command zfs $@ ;;
              esac
          }
        '';

        plugins = let
          oh-my-zsh = pkgs.fetchFromGitHub {
            owner = "robbyrussell";
            repo = "oh-my-zsh";
            rev = "d848c94804918138375041a9f800f401bec12068";
            sha256 = "0mxmqkdpimwrskqjri3lp3haj1hzf583g7psnv34y3hyymzcx1h6";
          };
          altKeyAvailable = with pkgs; !config.xsession.enable || (
            config.xsession.windowManager.command != "${i3}/bin/i3" &&
            config.xsession.windowManager.command != "${i3-gaps}/bin/i3"
          );
        in [
          {
            name = "nix-shell";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "fdf2899ac5e0623af97b4c7efaa312860f73964a";
              sha256 = "172p7fzg5rwc26wkr0zdc3rmyx9cl8k6dqwp72pn4ayv1j3y59r9";
            };
          }
          {
            name = "fast-syntax-highlighting";
            src = pkgs.fetchFromGitHub {
              owner = "zdharma";
              repo = "fast-syntax-highlighting";
              rev = "5fab542516579bdea5cc8b94137d9d85a0c3fda5";
              sha256 = "1ff1z2snbl9rx3mrcjbamlvc21fh9l32zi2hh9vcgcwbjwn5kikg";
            };
          }
          {
            name = "clipboard";
            file = "lib/clipboard.zsh";
            src = oh-my-zsh;
          }
          {
            name = "spectrum";
            file = "lib/spectrum.zsh";
            src = oh-my-zsh;
          }
          {
            name = "nicoulaj";
            file = "themes/nicoulaj.zsh-theme";
            src = oh-my-zsh;
          }
          {
            name = "colored-man-pages";
            file = "plugins/colored-man-pages/colored-man-pages.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "extract";
            file = "plugins/extract/extract.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "history";
            file = "plugins/history/history.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "sudo";
            file = "plugins/sudo/sudo.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "mercurial";
            file = "plugins/mercurial/mercurial.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "nyan";
            file = "plugins/nyan/nyan.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "gradle";
            file = "plugins/gradle/gradle.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "httpie";
            file = "plugins/httpie/httpie.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "copybuffer";
            file = "plugins/copybuffer/copybuffer.plugin.zsh";
            src = oh-my-zsh;
          }
          {
            name = "manydots-magic";
            file = "manydots-magic";
            src = pkgs.fetchFromGitHub {
              owner = "knu";
              repo = "zsh-manydots-magic";
              rev = "4372de0718714046f0c7ef87b43fc0a598896af6";
              sha256 = "0x7h41yhc9k1917zqghby3nhidw4x7mx5iwd1gqzjiw1wbpxxzln";
            };
          }
          {
            name = "dircycle";
            src = pkgs.fetchFromGitHub {
              owner = "michaelxmcbride";
              repo = "zsh-dircycle";
              rev = "31a421e459b75cdda341cf3ab2722697cec7d889";
              sha256 = "1cq9m99lsl753y7sszn5691817ky022wwz2mk6cr9djik541jydl";
            };
          }
          {
            name = "bd";
            src = pkgs.fetchFromGitHub {
              owner = "Tarrasch";
              repo = "zsh-bd";
              rev = "6853a136fc13ea9aa6af09c147b5a2a66d4aa620";
              sha256 = "1avra5cx8nxcqddwfj097ld0na9kwlq3z3akzqbzs4cd86wx7bzv";
            };
          }
        ] ++ (if altKeyAvailable then [
          {
            name = "zsh-editing-workbench";
            src = pkgs.fetchFromGitHub {
              owner = "psprint";
              repo = "zsh-editing-workbench";
              rev = "v1.0.3";
              sha256 = "0dyq7shj80iyd1j71hqf6p9n5mpmln077n3gsq2gv3a551dxvxrj";
            };
          }
        ] else [
          {
            name = "zsh-cmd-architect";
            src = pkgs.fetchFromGitHub {
              owner = "psprint";
              repo = "zsh-cmd-architect";
              rev = "v1.2";
              sha256 = "0pnps685926i8hxa9w5gxs4lnrz624ybnlrw428vnwyyg58s1a08";
            };
          }
        ]);
      };
    };
  };
}
