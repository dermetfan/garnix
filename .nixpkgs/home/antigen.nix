{
  target = ".antigenrc";
  text = ''
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
}
