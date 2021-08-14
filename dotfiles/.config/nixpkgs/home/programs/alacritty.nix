{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.alacritty;
in {
  options.config.programs.alacritty.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.alacritty.enable;
    defaultText = "<option>config.programs.alacritty.enable</option>";
    description = "Whether to configure Alacritty.";
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty.settings = {
      bell = {
        animation = "EaseOutSine";
        duration = 100;
      };

      background_opacity = 0.9;

      key_bindings = [
        { key = "Left";  mods = "Alt|Shift";     chars = "\\x1b[1;4D"; }
        { key = "Right"; mods = "Alt|Shift";     chars = "\\x1b[1;4C"; }
        { key = "Up";    mods = "Alt|Shift";     chars = "\\x1b[1;4A"; }
        { key = "Down";  mods = "Alt|Shift";     chars = "\\x1b[1;4D"; }
        { key = "Left";  mods = "Control|Shift"; chars = "\\x1b[1;6D"; }
        { key = "Right"; mods = "Control|Shift"; chars = "\\x1b[1;6C"; }
        { key = "Up";    mods = "Control|Shift"; chars = "\\x1b[1;6A"; }
        { key = "Down";  mods = "Control|Shift"; chars = "\\x1b[1;6B"; }
      ];

      selection.semantic_escape_chars = ",│`|\"' ()[]{}<>‘’";
    } // (if config.home.sessionVariables ? "SHELL" then {
      shell.program = config.home.sessionVariables.SHELL;
    } else {});
  };
}
