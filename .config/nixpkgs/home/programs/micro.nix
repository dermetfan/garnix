{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.micro;
in {
  options.config.programs.micro.enable = lib.mkEnableOption "micro";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.micro ];

      file.".config/micro/settings.json".text = ''
        {
          "autoclose": true,
          "autoindent": true,
          "autosave": false,
          "colorcolumn": 0,
          "colorscheme": "default",
          "cursorline": true,
          "eofnewline": true,
          "ftoptions": true,
          "ignorecase": true,
          "indentchar": " ",
          "infobar": true,
          "keepautoindent": false,
          "linter": true,
          "pluginchannels": [ "https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json" ],
          "pluginrepos": [],
          "rmtrailingws": true,
          "ruler": false,
          "savecursor": true,
          "saveundo": false,
          "scrollmargin": 3,
          "scrollspeed": 2,
          "softwrap": false,
          "splitBottom": true,
          "splitRight": true,
          "statusline": true,
          "syntax": true,
          "tabmovement": true,
          "tabsize": 4,
          "tabstospaces": true,
          "termtitle": true,
          "useprimary": true,

          "*.nix": { "tabsize": 2 }
        }
      '';
    };
  };
}
