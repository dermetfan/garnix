{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.mercurial;
in {
  options.profiles.dermetfan.programs.mercurial.enable = lib.mkEnableOption "mercurial" // {
    default = config.programs.mercurial.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.meld ];

    programs.mercurial = {
      userName  = "Robin Stumm";
      userEmail = "serverkorken@gmail.com";

      aliases = {
        lg   = "log -G";
        qnew = "qnew -e";
      };

      extraConfig = {
        ui = {
          merge = "meld";
          ssh = "ssh -C";
          "interface.chunkselector" = "curses";
        };

        auth = {
          "bb.prefix" = https://bitbucket.org/;
          "bb.username" = "dermetfan";
          "gh.prefix" = https://github.com/;
          "gh.username" = "dermetfan";
        };

        merge-tools."meld.args" = "$base $local $other";

        extensions = {
          color    = "";
          progress = "";
          shelve   = "";
          strip    = "";
          purge    = "";
          pager    = "";
          eol      = "";
          convert  = "";
          rebase   = "";
          histedit = "";
          mq       = "";
        };

        pager = {
          pager = "less";
          attend = "lg, log, diff, annotate, help";
        };

        diff.git = true;

        mq.secret = true;
      };
    };
  };
}
