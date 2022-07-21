{
  programs.git = {
    delta = {
      enable = true;
      options.syntax-theme = "gruvbox-dark";
    };

    userName = "Robin Stumm";
    userEmail = "serverkorken@gmail.com";

    aliases = {
      st = "status --short";
      lg = "log --graph --decorate --abbrev-commit --pretty=medium";
      co = "checkout";
      ci = "commit";
      spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
    };

    extraConfig = {
      status.submoduleSummary = true;
      diff.submodule = "log";
      pull.ff = "only";
    };
  };
}
