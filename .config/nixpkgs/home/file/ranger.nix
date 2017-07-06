[
  {
    target = ".config/ranger/rc.conf";
    text = ''
      set confirm_on_delete always
      set vcs_aware true
      set vcs_backend_hg local
      set vcs_backend_git local
      set unicode_ellipsis true
      set tilde_in_titlebar true
    '';
  }
  {
    target = ".config/ranger/rifle.conf";
    text = ''
      ext x?html?, X, has vivaldi, flag f = vivaldi -- "$@"
      mime ^text,  X, has geany,   flag f = geany   -- "$@"
    '';
  }
]
