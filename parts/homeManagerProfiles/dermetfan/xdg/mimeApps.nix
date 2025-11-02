{ config, lib, ... }: {
  programs = {
    mimeo = {
      enable = true;
      xdgOpen = true;
    };

    kakoune.enable = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "kakoune.desktop" ];
    } // lib.optionalAttrs config.programs.firefox.enable {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}
