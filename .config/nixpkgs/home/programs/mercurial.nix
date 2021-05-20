{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.mercurial;
in {
  options.config.programs.mercurial.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.mercurial.enable;
    defaultText = "<option>programs.mercurial.enable</option>";
    description = "Whether to configure Mercurial.";
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

        alias.st = "!$HG status $($HG root) $HG_ARGS";

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
