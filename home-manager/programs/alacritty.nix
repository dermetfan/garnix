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
        { mode = "Vi|~Search"; key = "R";        mods = "Shift";   action = "ScrollLineUp";            }
        { mode = "Vi|~Search"; key = "I";        mods = "Shift";   action = "ScrollLineDown";          }
        { mode = "Vi|~Search"; key = "PageUp";                     action = "ScrollPageUp";            }
        { mode = "Vi|~Search"; key = "PageDown";                   action = "ScrollPageDown";          }
        { mode = "Vi|~Search"; key = "PageUp";   mods = "Shift";   action = "ScrollHalfPageUp";        }
        { mode = "Vi|~Search"; key = "PageDown"; mods = "Shift";   action = "ScrollHalfPageDown";      }
        { mode = "Vi|~Search"; key = "Space";                      action = "ToggleNormalSelection";   }
        { mode = "Vi|~Search"; key = "Space";    mods = "Shift";   action = "ToggleLineSelection";     }
        { mode = "Vi|~Search"; key = "Space";    mods = "Control"; action = "ToggleBlockSelection";    }
        { mode = "Vi|~Search"; key = "Space";    mods = "Alt";     action = "ToggleSemanticSelection"; }
        { mode = "Vi|~Search"; key = "R";                          action = "Up";                      }
        { mode = "Vi|~Search"; key = "I";                          action = "Down";                    }
        { mode = "Vi|~Search"; key = "N";                          action = "Left";                    }
        { mode = "Vi|~Search"; key = "O";                          action = "Right";                   }
      ];

      selection.semantic_escape_chars = ",│`|\"' ()[]{}<>‘’";
    } // (if config.home.sessionVariables ? "SHELL" then {
      shell.program = config.home.sessionVariables.SHELL;
    } else {});
  };
}
