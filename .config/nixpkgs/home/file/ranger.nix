[
  {
    target = ".config/ranger/rc.conf";
    text = ''
      set use_preview_script false
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
      mime ^text,     has nano            = nano    -- "$@"
      mime ^text,  X, has geany,   flag f = geany   -- "$@"
      ext x?html?, X, has vivaldi, flag f = vivaldi -- "$@"
    '';
  }
  {
    target = ".config/ranger/bookmarks";
    text = ''
      d:/data/dermetfan
      ':/home/dermetfan
    '';
  }
]
