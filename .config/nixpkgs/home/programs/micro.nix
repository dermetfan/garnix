{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.micro;
in {
  options       .programs.micro.enable = lib.mkEnableOption "micro";
  options.config.programs.micro.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.micro.enable;
    defaultText = "<option>config.programs.micro.enable</option>";
    description = "Whether to configure micro.";
  };

  config.home.packages = with pkgs; lib.optionals config.programs.micro.enable [
    micro
    mkinfo
  ];
  config.home.file = lib.mkIf cfg.enable {
    ".config/micro/settings.json".text = builtins.toJSON {
      eofnewline = true;
      ignorecase = true;
      indentchar = " ";
      ruler = false;
      savecursor = true;
      saveundo = true;
      tabstospaces = true;
      tabmovement = true;
      termtitle = true;

      /* Options added by plugins need to be provided
       * or micro will attempt to save them on startup. */
      autoclose = true;
      linter = true;
      ftoptions = true;
      trimdiff = false;

      "*.nix" = {
        tabsize = 2;
      };

      /* Include defaults to stop micro >= 1.4.0 from trying
       * to write missing settings on startup. */
      autoindent = true;
      autosave = false;
      basename = false;
      colorcolumn = 0;
      colorscheme = "default";
      cursorline = true;
      fastdirty = true;
      fileformat = "unix";
      infobar = true;
      keepautoindent = false;
      keymenu = false;
      literate = true;
      matchbrace = false;
      mouse = true;
      pluginchannels = [
        https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json
      ];
      pluginrepos = [];
      rmtrailingws = false;
      savehistory = true;
      scrollbar = false;
      scrollmargin = 3;
      scrollspeed = 2;
      softwrap = false;
      splitbottom = true;
      splitright = true;
      statusline = true;
      sucmd = "sudo";
      syntax = true;
      tabsize = 4;
      useprimary = true;
    };

    ".config/micro/bindings.json".text = builtins.toJSON {
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
