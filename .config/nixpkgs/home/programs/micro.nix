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
        };

        ".config/micro/plugins/vcs".source = pkgs.fetchFromBitbucket {
          owner = "dermetfan";
          repo = "micro-vcs";
          rev = "e2311b9c1b360e3ca9ffd534e80a115578fa8fca";
          sha256 = "1kcz1a6cvb0afnc21f33vjwc0jfgdilb8wphf04csldd8n9gqbfx";
        };
      };
    };
  };
}
