{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.wyrd;
in {
  options.profiles.dermetfan.programs.wyrd.enable = lib.mkEnableOption "wyrd" // {
    default = config.programs.wyrd.enable or false;
  };

  config = lib.mkIf cfg.enable {
    home.file.".wyrdrc".text = ''
      include "${pkgs.wyrd}/etc/wyrdrc"

      set reminders_file="$XDG_DATA_HOME/remind"
      set week_starts_monday="true"
      set selection_12_hour="false"
      set status_12_hour="false"
      set description_12_hour="false"
      set center_cursor="true"
      set number_weeks="true"
      set advance_warning="true"
      set untimed_bold="false"

      # NIRO key navigation with swapped shift
      unbind "J"
      bind "I" scroll_down
      unbind "K"
      bind "R" scroll_up
      unbind "H"
      bind "N" switch_window
      unbind "L"
      bind "O" switch_window
      unbind "h"
      bind "n" previous_day
      unbind "l"
      bind "o" next_day
      unbind "k"
      bind "r" previous_week
      unbind "j"
      bind "i" next_week

      # substitutes for remapped NIRO keys
      bind "v" view_remind
      bind "V" view_remind_all
      bind "j" search_next

      unbind "Q"
      bind "q" quit
      bind "a" quick_add

      bind "<pageup>" scroll_up
      bind "<pagedown>" scroll_down

      color left_divider   yellow default
      color right_divider  yellow default
      color selection_info yellow default
      color status         yellow default
      color help           yellow default
      color timed_default white default
      color timed_current white red
      color timed_date green default
      color untimed_reminder default default
      color description default default
      color calendar_labels green default
      color calendar_level1 white default
      color calendar_level2 magenta default
      color calendar_level3 cyan default
    '';
  };
}
