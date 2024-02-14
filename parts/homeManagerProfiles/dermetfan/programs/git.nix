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
      st = "status --short";
      lg = "log --graph --decorate --abbrev-commit --pretty=medium";
      co = "checkout";
      ci = "commit";
      pl = "pull --prune";
      spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
    };

    extraConfig = {
      status.submoduleSummary = true;
      diff = {
        submodule = "log";
        colorMoved = "default";
        colorMovedWS = "allow-indentation-change";
        noprefix = true;
      };
      pull.ff = "only";
      fetch.writeCommitGraph = true;
      gc.writeCommitGraph = true;
      rerere.enabled = true;
    };
  };
}
