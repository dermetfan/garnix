{
  imports = [
    # https://github.com/nix-community/home-manager/issues/3140
    ({ config, lib, pkgs, ... }: {
      programs.git = {
        difftastic = {
          background = "dark";
          display = "inline";
        };

        extraConfig = {
          diff.tool = "difftastic";
          difftool = {
            prompt = false;
            difftastic.cmd = let
              cfg = config.programs.git.difftastic;
            in toString [
              (lib.getExe pkgs.difftastic)
              "--color ${cfg.color}"
              "--background ${cfg.background}"
              "--display ${cfg.display}"
              ''"$LOCAL" "$REMOTE"''
            ];
          };
        };
      };
    })
  ];

  programs.git = {
    delta = {
      enable = true;
      options = {
        syntax-theme = "gruvbox-dark";
        features = "zebra-dark";
      };
    };

    userName = "Robin Stumm";
    userEmail = "serverkorken@gmail.com";

    aliases = {
      st = "status";
      lg = "log --graph";
      co = "checkout";
      ci = "commit";
      spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
    };

    extraConfig = {
      log = {
        abbrevCommit = true;
        date = "iso";
        decorate = true;
        initialDecorationSet = "all";
      };
      status = {
        short = true;
        submoduleSummary = true;
      };
      diff = {
        submodule = "log";
        colorMoved = "default";
        colorMovedWS = "allow-indentation-change";
        noprefix = true;
      };
      push.autoSetupRemote = true;
      pull.ff = "only";
      fetch = {
        prune = true;
        pruneTags = true;
        writeCommitGraph = true;
      };
      format.pretty = "short";
      gc.writeCommitGraph = true;
      rerere.enabled = true;
      revert.reference = true;
      rebase = {
        rescheduleFailedExec = true;
        missingCommitsCheck = "warn";
        updateRefs = true;
      };
      interactive.singleKey = true;
    };
  };
}
