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
      rmtrailingws = true;
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
