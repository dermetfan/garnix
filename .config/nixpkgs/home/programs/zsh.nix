{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enableCompletion = let
      sysZshCfg = config.passthru.systemConfig.programs.zsh or {
        enable = true;
        enableCompletion = true;
      };
    in !sysZshCfg.enable || !sysZshCfg.enableCompletion;

    initExtra = ''
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
      altKeyAvailable = with pkgs;
          config.xsession.enable &&
          config.xsession.windowManager.command != "${i3}/bin/i3" &&
          config.xsession.windowManager.command != "${i3-gaps}/bin/i3";
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
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.4.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
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
      {
        name = "zed-zsh";
        file = "zed.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "eendroroy";
          repo = "zed-zsh";
          rev = "17560e8d342947ec9dbed65b4befb12c9c5d5366";
          sha256 = "14la3j4bip23lxhla4yhn9j9g98zzi9yhncqg2l3963sdci8hl0n";
          fetchSubmodules = true;
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
}
