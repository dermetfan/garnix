{ config, lib, pkgs, ... }:

let
  cfg = config.programs.tkremind;

  colorschemes.gruvbox-light = ''
    WinBackground #a89984
    BackgroundColor #d5c4a1
    LabelColor #af3a03
    TextColor #3c3836
  '';
in {
  options.programs.tkremind = with lib; {
    enable = mkEnableOption "tkremind";

    reminders = let
      option = mkOption {
        type = types.path;
        default = "${config.xdg.dataHome}/remind";
      };
    in {
      read = option;
      write = option // { default = cfg.reminders.read; };
    };

    font = {
      family = mkOption {
        type = types.str;
        default = "DejaVu Sans";
      };
      size = mkOption {
        type = types.int;
        default = 11;
      };
    };

    colorscheme = mkOption {
      type = with types; nullOr (enum [ "gruvbox-light" ]);
      default = null;
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };

    extraArgs = mkOption {
      type = types.str;
      default = "";
    };
  };

  options.config.programs.tkremind.enable = lib.mkEnableOption "tkremind settings" // {
    default = cfg.enable;
  };

  config = lib.mkIf cfg.enable {
    programs = lib.mkIf config.config.programs.tkremind.enable {
      tkremind = {
        colorscheme = "gruvbox-light";
        extraArgs = "-m -b1";
        extraConfig = ''
          AutoClose 1
          ShowTodaysReminders 0
          Editor {alacritty -e ${config.home.sessionVariables.EDITOR} +%d %s}
        '';
      };

      alacritty.enable = true;
      geany.enable = true;
    };

    home = {
      packages = [ pkgs.remind ];

      file.".tkremindrc".text = ''
        HeadingFont {-family {${cfg.font.family}} -size ${toString cfg.font.size} -weight normal -slant roman -underline 0 -overstrike 0}
        CalboxFont  {-family {${cfg.font.family}} -size ${toString cfg.font.size} -weight normal -slant roman -underline 0 -overstrike 0}
      '' + lib.optionalString (cfg.colorscheme != null) ''
        ${colorschemes.${cfg.colorscheme}}
      '' + lib.optionalString (config.home.sessionVariables ? EDITOR) ''
        Editor {${config.home.sessionVariables.EDITOR} +%d %s}
      '' + cfg.extraConfig;
    };

    xdg.desktopEntries.tkremind = {
      name = "TkRemind";
      genericName = "Calendar";
      exec = "tkremind ${cfg.extraArgs} ${cfg.reminders.read} ${cfg.reminders.write}";
      categories = [ "Office" "Calendar" ];
      mimeType = [ "text/plain" ];
    };
  };
}

