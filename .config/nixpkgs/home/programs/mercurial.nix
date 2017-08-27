{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.mercurial;
in {
  options.config.programs.mercurial.enable = lib.mkEnableOption "mercurial";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.mercurial ];

      file.".hgrc".text = ''
        [ui]
        username = Robin Stumm <serverkorken@gmail.com>
        editor = nano
        merge = meld
        ssh = ssh -C
        interface.chunkselector = curses

        [alias]
        lg = log -G
        qnew = qnew -e

        [auth]
        bb.prefix = https://bitbucket.org/
        bb.username = dermetfan
        gh.prefix = https://github.com/
        gh.username = dermetfan

        [merge-tools]
        meld.args = $base $local $other

        [extensions]
        color =
        progress =
        shelve =
        strip =
        purge =
        pager =
        eol =
        convert =
        rebase =
        histedit =
        mq =

        [pager]
        pager = less
        attend = lg, log, diff, annotate, help

        [diff]
        git = true

        [mq]
        secret = true
      '';
    };
  };
}
