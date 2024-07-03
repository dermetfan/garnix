{
  programs.alacritty.settings = {
    bell = {
      animation = "EaseOutSine";
      duration = 100;
    };

    window.opacity = 0.9;

    keyboard.bindings = [
      { key = "Left";  mods = "Alt|Shift";     chars = ''\\x1b[1;4D''; }
      { key = "Right"; mods = "Alt|Shift";     chars = ''\\x1b[1;4C''; }
      { key = "Up";    mods = "Alt|Shift";     chars = ''\\x1b[1;4A''; }
      { key = "Down";  mods = "Alt|Shift";     chars = ''\\x1b[1;4D''; }
      { key = "Left";  mods = "Control|Shift"; chars = ''\\x1b[1;6D''; }
      { key = "Right"; mods = "Control|Shift"; chars = ''\\x1b[1;6C''; }
      { key = "Up";    mods = "Control|Shift"; chars = ''\\x1b[1;6A''; }
      { key = "Down";  mods = "Control|Shift"; chars = ''\\x1b[1;6B''; }
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

    # https://github.com/alacritty/alacritty/wiki/Color-schemes#gruvbox (Gruvbox dark)
    colors = let
      gruvbox_dark_bg = "#1d2021";
    in {
      primary = {
        background        = gruvbox_dark_bg;
        foreground        = "#ebdbb2";
        bright_foreground = "#fbf1c7";
        dim_foreground    = "#a89984";
      };
      cursor = {
        text   = "CellBackground";
        cursor = "CellForeground";
      };
      vi_mode_cursor = {
        text   = "CellBackground";
        cursor = "CellForeground";
      };
      selection = {
        text       = "CellBackground";
        background = "CellForeground";
      };
      bright = {
        black   = "#928374";
        red     = "#fb4934";
        green   = "#b8bb26";
        yellow  = "#fabd2f";
        blue    = "#83a598";
        magenta = "#d3869b";
        cyan    = "#8ec07c";
        white   = "#ebdbb2";
      };
      normal = {
        black   = gruvbox_dark_bg;
        red     = "#cc241d";
        green   = "#98971a";
        yellow  = "#d79921";
        blue    = "#458588";
        magenta = "#b16286";
        cyan    = "#689d6a";
        white   = "#a89984";
      };
      dim = {
        black   = "#32302f";
        red     = "#9d0006";
        green   = "#79740e";
        yellow  = "#b57614";
        blue    = "#076678";
        magenta = "#8f3f71";
        cyan    = "#427b58";
        white   = "#928374";
      };
    };
  };
}
