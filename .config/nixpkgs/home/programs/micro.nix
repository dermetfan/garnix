{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.micro;
in {
  options.config.programs.micro.enable = lib.mkEnableOption "micro";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.micro ];

      file = {
        ".config/micro/settings.json".text = builtins.toJSON {
          eofnewline = true;
          ignorecase = true;
          indentchar = " ";
          rmtrailingws = true;
          ruler = false;
          savecursor = true;
          tabstospaces = true;
          tabmovement = true;
          termtitle = true;

          /* Options added by plugins need to be provided
           * or micro will attempt to save them on startup. */
          autoclose = true;
          linter = true;
          ftoptions = true;

          "*.nix" = {
            tabsize = 2;
          };
        };

        ".config/micro/bindings.json".text = builtins.toJSON {
          Esc = "RemoveAllMultiCursors,ClearStatus,Escape";
          Alt-m = "SpawnMultiCursor";
          Alt-M = "RemoveMultiCursor";
          Alt-p = "SkipMultiCursor";
          "Alt-[" = "ScrollUp";
          "Alt-]" = "ScrollDown";
          CtrlM = "Center";
          CtrlH = "Suspend";
        };
      };
    };
  };
}
