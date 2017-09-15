{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.alacritty;
in {
  options.config.programs.alacritty.enable = lib.mkEnableOption "Alacritty";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.alacritty ];

      file.".config/alacritty/alacritty.yml".text = ''
        visual_bell:
          animation: EaseOutSine
          duration: 100

        background_opacity: 0.7

        key_bindings:
          - { key: Left,  mods: Alt|Shift,     chars: "\x1b[1;4D" }
          - { key: Right, mods: Alt|Shift,     chars: "\x1b[1;4C" }
          - { key: Up,    mods: Alt|Shift,     chars: "\x1b[1;4A" }
          - { key: Down,  mods: Alt|Shift,     chars: "\x1b[1;4D" }
          - { key: Left,  mods: Control|Shift, chars: "\x1b[1;6D" }
          - { key: Right, mods: Control|Shift, chars: "\x1b[1;6C" }
          - { key: Up,    mods: Control|Shift, chars: "\x1b[1;6A" }
          - { key: Down,  mods: Control|Shift, chars: "\x1b[1;6B" }
          # defaults
          - { key: V,        mods: Control|Shift,    action: Paste               }
          - { key: C,        mods: Control|Shift,    action: Copy                }
          - { key: Q,        mods: Command, action: Quit                         }
          - { key: W,        mods: Command, action: Quit                         }
          - { key: Insert,   mods: Shift,   action: PasteSelection               }
          - { key: Home,                    chars: "\x1bOH",   mode: AppCursor   }
          - { key: Home,                    chars: "\x1b[H",   mode: ~AppCursor  }
          - { key: End,                     chars: "\x1bOF",   mode: AppCursor   }
          - { key: End,                     chars: "\x1b[F",   mode: ~AppCursor  }
          - { key: PageUp,   mods: Shift,   chars: "\x1b[5;2~"                   }
          - { key: PageUp,   mods: Control, chars: "\x1b[5;5~"                   }
          - { key: PageUp,                  chars: "\x1b[5~"                     }
          - { key: PageDown, mods: Shift,   chars: "\x1b[6;2~"                   }
          - { key: PageDown, mods: Control, chars: "\x1b[6;5~"                   }
          - { key: PageDown,                chars: "\x1b[6~"                     }
          - { key: Left,     mods: Shift,   chars: "\x1b[1;2D"                   }
          - { key: Left,     mods: Control, chars: "\x1b[1;5D"                   }
          - { key: Left,     mods: Alt,     chars: "\x1b[1;3D"                   }
          - { key: Left,                    chars: "\x1b[D",   mode: ~AppCursor  }
          - { key: Left,                    chars: "\x1bOD",   mode: AppCursor   }
          - { key: Right,    mods: Shift,   chars: "\x1b[1;2C"                   }
          - { key: Right,    mods: Control, chars: "\x1b[1;5C"                   }
          - { key: Right,    mods: Alt,     chars: "\x1b[1;3C"                   }
          - { key: Right,                   chars: "\x1b[C",   mode: ~AppCursor  }
          - { key: Right,                   chars: "\x1bOC",   mode: AppCursor   }
          - { key: Up,       mods: Shift,   chars: "\x1b[1;2A"                   }
          - { key: Up,       mods: Control, chars: "\x1b[1;5A"                   }
          - { key: Up,       mods: Alt,     chars: "\x1b[1;3A"                   }
          - { key: Up,                      chars: "\x1b[A",   mode: ~AppCursor  }
          - { key: Up,                      chars: "\x1bOA",   mode: AppCursor   }
          - { key: Down,     mods: Shift,   chars: "\x1b[1;2B"                   }
          - { key: Down,     mods: Control, chars: "\x1b[1;5B"                   }
          - { key: Down,     mods: Alt,     chars: "\x1b[1;3B"                   }
          - { key: Down,                    chars: "\x1b[B",   mode: ~AppCursor  }
          - { key: Down,                    chars: "\x1bOB",   mode: AppCursor   }
          - { key: Tab,      mods: Shift,   chars: "\x1b[Z"                      }
          - { key: F1,                      chars: "\x1bOP"                      }
          - { key: F2,                      chars: "\x1bOQ"                      }
          - { key: F3,                      chars: "\x1bOR"                      }
          - { key: F4,                      chars: "\x1bOS"                      }
          - { key: F5,                      chars: "\x1b[15~"                    }
          - { key: F6,                      chars: "\x1b[17~"                    }
          - { key: F7,                      chars: "\x1b[18~"                    }
          - { key: F8,                      chars: "\x1b[19~"                    }
          - { key: F9,                      chars: "\x1b[20~"                    }
          - { key: F10,                     chars: "\x1b[21~"                    }
          - { key: F11,                     chars: "\x1b[23~"                    }
          - { key: F12,                     chars: "\x1b[24~"                    }
          - { key: Back,                    chars: "\x7f"                        }
          - { key: Back,     mods: Alt,     chars: "\x1b\x7f"                    }
          - { key: Insert,                  chars: "\x1b[2~"                     }
          - { key: Delete,                  chars: "\x1b[3~"                     }

        selection:
          semantic_escape_chars: ",│`|\"' ()[]{}<>‘’"
      '';
    };
  };
}
