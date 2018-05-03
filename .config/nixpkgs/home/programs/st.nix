{ config, lib, pkgs, ... }:

let
  cfg = config.programs.st;
in {
  options.programs.st.enable = lib.mkEnableOption "st";

  config.home = lib.mkIf cfg.enable {
    packages = lib.optional config.programs.st.enable pkgs.st;

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
}
