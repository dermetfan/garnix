{ config, lib, pkgs, ... }: {
  programs = {
    git.settings = {
      user = {
        name = "Robin Stumm";
        email = "serverkorken@gmail.com";
      };
      aliases = {
        st = "status";
        lg = "log --graph";
        co = "checkout";
        ci = "commit";
        spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
        # XXX Use https://github.com/wtnqk/ftdv instead once it's packaged.
        # That supports configuring other diffing tools (such as difftastic),
        # while diffnav is hardcoded to use delta.
        diffnav = "-c core.pager='${lib.getExe pkgs.diffnav} --unified' diff";
      };
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
        algorithm = "histogram";
        submodule = "log";
        colorMoved = "default";
        colorMovedWS = "allow-indentation-change";
        noPrefix = true;
        tool = "difftastic";
      };
      difftool = {
        prompt = false;
        # There's an assertion in the home-manager modules
        # that forbids to set `programs.{delta,difftastic}.git.enable`
        # at the same time, for no good reason IMHO.
        # This line is essentially copied from the difftastic module.
        difftastic.cmd = with config.programs.difftastic; toString [
          (lib.getExe package)
          (lib.cli.toGNUCommandLineShell {} options)
          "$LOCAL"
          "$REMOTE"
        ];
      };
      branch.sort = "committerdate";
      tag.sort = "version:refname";
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      pull.ff = "only";
      fetch = {
        prune = true;
        pruneTags = true;
        writeCommitGraph = true;
      };
      format.pretty = "oneline-ext";
      pretty = {
        oneline-ext = lib.concatStrings [
          "format:"
          "%C(auto)%h%Creset"
          " %Cgreen%ad%Creset"
          " %Cblue%an%Creset"
          "%C(auto)%d"
          " %s"
        ];
        medium-ext = lib.concatStrings [
          "format:"
          "%C(auto)%h%d%n"
          "%Cblue%an <%ae>%n"
          "%Cgreen%ad%n"
          "%n"
          "%C(auto)%x09%s%n%n"
          "%x09%b"
        ];
      };
      gc.writeCommitGraph = true;
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      revert.reference = true;
      rebase = {
        rescheduleFailedExec = true;
        missingCommitsCheck = "warn";
        updateRefs = true;
      };
      interactive.singleKey = true;
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        syntax-theme = "gruvbox-dark";
        features = "zebra-dark";
      };
    };

    difftastic = {
      enable = true;
      options = {
        background = "dark";
        display = "inline";
      };
    };
  };
}
