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
          saveundo = true;
          tabstospaces = true;
          tabmovement = true;
          termtitle = true;
          pluginrepos = [
            https://bitbucket.org/dermetfan/micro-vcs/raw/default/repo.json
          ];

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
          Alt-y = "Center";
          CtrlH = "Suspend";
        };

        ".config/micro/plugins/vcs".source = pkgs.fetchFromBitbucket {
          owner = "dermetfan";
          repo = "micro-vcs";
          rev = "6832f058a76951b3af46d3e05e700e3fcdaf7f74";
          sha256 = "16nyjgv1vkr9bjyk4ijpsfnh791dwdca0bsp1ma7h7143ppk9f16";
        };
      };
    };
  };
}
