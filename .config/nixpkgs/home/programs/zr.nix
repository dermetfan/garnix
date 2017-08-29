{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.zr;

  altKeyAvailable = with pkgs;
    config.xsession.windowManager != "${i3}/bin/i3" &&
    config.xsession.windowManager != "${i3-gaps}/bin/i3";
in {
  options.config.programs.zr.enable = lib.mkEnableOption "z:rat";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        zr
        fzy # enhancd
      ];
    };

    programs.zsh.initExtra = ''
      if [[ ! -f ~/.zr/init.zsh ]]; then
          zr load \
              chrissicool/zsh-256color \
              zdharma/fast-syntax-highlighting \
              zsh-users/zsh-autosuggestions \
              b4b4r07/enhancd \
              robbyrussell/oh-my-zsh/lib/clipboard.zsh \
              robbyrussell/oh-my-zsh/lib/spectrum.zsh \
              robbyrussell/oh-my-zsh/themes/nicoulaj.zsh-theme \
              robbyrussell/oh-my-zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/extract/extract.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/history/history.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/sudo/sudo.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/mercurial/mercurial.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/nyan/nyan.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/gradle/gradle.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/httpie/httpie.plugin.zsh \
              robbyrussell/oh-my-zsh/plugins/copybuffer/copybuffer.plugin.zsh \
              knu/zsh-manydots-magic/manydots-magic \
              michaelxmcbride/zsh-dircycle \
              Tarrasch/zsh-bd \
              voronkovich/project.plugin.zsh \
              eendroroy/zed-zsh \
              psprint/${if altKeyAvailable then "zsh-editing-workbench" else "zsh-cmd-architect"}

          # for some reason this loads faster
          # if compinit is called first
          tmp=`mktemp`
          tail -n1   ~/.zr/init.zsh >> $tmp
          head -n-1  ~/.zr/init.zsh >> $tmp
          cat $tmp > ~/.zr/init.zsh
          rm $tmp
      fi
      . ~/.zr/init.zsh
    '';
  };
}
