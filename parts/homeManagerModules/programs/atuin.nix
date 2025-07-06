{
  programs.atuin = {
    daemon.enable = true;
    settings = {
      update_check = false;
      sync.records = true;
      dotfiles.enabled = false;
    };
  };
}
