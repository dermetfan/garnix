{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.st;
in {
  options.config.programs.st.enable = lib.mkEnableOption "st";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.st ];

      file.".local/share/applications/simple-terminal.desktop".text = ''
        [Desktop Entry]
        Name=Simple Terminal
        GenericName=Terminal
        Comment=suckless st
        Exec=st
        Terminal=false
        Type=Application
        Encoding=UTF-8
        Icon=terminal
        Categories=System;TerminalEmulator;
        Keywords=shell;prompt;command;commandline;cmd;
      '';
    };
  };
}
