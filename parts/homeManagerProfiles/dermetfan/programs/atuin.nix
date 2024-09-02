{
  programs.atuin = {
    flags = [ "--disable-up-arrow" ];
    settings = {
      enter_accept = false;
      filter_mode = "directory";
      workspaces = true;
      invert = true;
      show_tabs = false;
    };
  };
}
