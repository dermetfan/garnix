{ config, lib, ... }:

{
  home.file.".antigenrc".text = ''
    antigen use oh-my-zsh

    antigen theme nicoulaj

    antigen bundles <<EOS
      zsh-users/zsh-syntax-highlighting
      colored-man-pages
      dircycle
      extract
      history
      sudo
      mosh
      tmux
      urltools
      gradle
      mercurial
      git
      nyan
    EOS
    antigen bundle web-search; alias open_command=xdg-open

    antigen apply
  '';

  programs.zsh.initExtra = ''
    if [[ -f ~/.antigen/antigen.zsh ]]; then
        . ~/.antigen/antigen.zsh
        antigen init ~/.antigenrc
    fi

    ${# apply aliases again, antigen may have changed them
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (k: v: "alias ${k}='${v}'") config.passthru.programs.zsh.shellAliases
      )}
  '';
}
