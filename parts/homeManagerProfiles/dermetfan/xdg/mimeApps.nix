{
  programs = {
    mimeo = {
      enable = true;
      xdgOpen = true;
    };

    kakoune.enable = true;
    firefox.enable = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "kakoune.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}
