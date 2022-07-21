{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.micro;
in {
  options.profiles.dermetfan.programs.micro.enable = lib.mkEnableOption "micro" // {
    default = config.programs.micro.enable;
  };

  config.xdg.configFile = {
    "micro/settings.json".text = builtins.toJSON {
      eofnewline = true;
      ignorecase = true;
      ruler = false;
      savecursor = true;
      saveundo = true;
      tabmovement = true;
      termtitle = true;
      matchbrace = true;
      basename = true;
      rmtrailingws = true;
      softwrap = true;

      "*.nix" = {
        tabsize = 2;
        tabstospaces = true;
      };
      "*.zig" = {
        tabstospaces = true;
      };
      "*.sql" = {
        tabsize = 2;
      };
      "*.md" = {
        rmtrailingws = false;
      };

      /* Options added by plugins need to be provided
       * or micro will attempt to save them on startup. */
      autoclose = true;
      linter = true;
      ftoptions = true;
      trimdiff = false;

      /* Include defaults to stop micro >= 1.4.0 from trying
       * to write missing settings on startup. */
      autoindent = true;
      autosave = false;
      colorcolumn = 0;
      colorscheme = "default";
      cursorline = true;
      fastdirty = true;
      fileformat = "unix";
      indentchar = "\t";
      infobar = true;
      keepautoindent = false;
      keymenu = false;
      literate = true;
      mouse = true;
      pluginchannels = [
        https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json
      ];
      pluginrepos = [];
      savehistory = true;
      scrollbar = false;
      scrollmargin = 3;
      scrollspeed = 2;
      splitbottom = true;
      splitright = true;
      statusline = true;
      sucmd = "sudo";
      syntax = true;
      tabsize = 4;
      tabstospaces = false;
      useprimary = true;
    };

    "micro/bindings.json".text = builtins.toJSON {
      Esc = "RemoveAllMultiCursors,ClearStatus,Escape";
      Alt-m = "SpawnMultiCursor";
      Alt-M = "RemoveMultiCursor";
      Alt-p = "SkipMultiCursor";
      "Alt-[" = "ScrollUp";
      "Alt-]" = "ScrollDown";
      Alt-y = "Center";
      CtrlH = "Suspend";
      CtrlG = "vcs.toggle";
    };
  };
}
