{ pkgs, ... }:

{
  home.packages = [ pkgs.broot-vscode-font ];

  programs.broot.settings = {
    default_flags = "g";
    icon_theme = "vscode";

    skin = {
      # https://dystroy.org/broot/skins/#gruvbox
      default = "rgb(235, 219, 178) none / rgb(189, 174, 147) none";
      tree = "rgb(168, 153, 132) None / rgb(102, 92, 84) None";
      parent = "rgb(235, 219, 178) none / rgb(189, 174, 147) none Italic";
      file = "None None / None  None Italic";
      directory = "rgb(131, 165, 152) None Bold / rgb(131, 165, 152) None";
      exe = "rgb(184, 187, 38) None";
      link = "rgb(104, 157, 106) None";
      pruning = "rgb(124, 111, 100) None Italic";
      perm__ = "None None";
      perm_r = "rgb(215, 153, 33) None";
      perm_w = "rgb(204, 36, 29) None";
      perm_x = "rgb(152, 151, 26) None";
      owner = "rgb(215, 153, 33) None Bold";
      group = "rgb(215, 153, 33) None";
      count = "rgb(69, 133, 136) rgb(50, 48, 47)";
      dates = "rgb(168, 153, 132) None";
      sparse = "rgb(250, 189,47) None";
      content_extract = "ansi(29) None Italic";
      content_match = "ansi(34) None Bold";
      git_branch = "rgb(251, 241, 199) None";
      git_insertions = "rgb(152, 151, 26) None";
      git_deletions = "rgb(190, 15, 23) None";
      git_status_current = "rgb(60, 56, 54) None";
      git_status_modified = "rgb(152, 151, 26) None";
      git_status_new = "rgb(104, 187, 38) None Bold";
      git_status_ignored = "rgb(213, 196, 161) None";
      git_status_conflicted = "rgb(204, 36, 29) None";
      git_status_other = "rgb(204, 36, 29) None";
      selected_line = "None rgb(60, 56, 54) / None rgb(50, 48, 47)";
      char_match = "rgb(250, 189, 47) None";
      file_error = "rgb(251, 73, 52) None";
      flag_label = "rgb(189, 174, 147) None";
      flag_value = "rgb(211, 134, 155) None Bold";
      input = "rgb(251, 241, 199) None / rgb(189, 174, 147) None Italic";
      status_error = "rgb(213, 196, 161) rgb(204, 36, 29)";
      status_job = "rgb(250, 189, 47) rgb(60, 56, 54)";
      status_normal = "None rgb(40, 38, 37) / None None";
      status_italic = "rgb(211, 134, 155) rgb(40, 38, 37) Italic / None None";
      status_bold = "rgb(211, 134, 155) rgb(40, 38, 37) Bold / None None";
      status_code = "rgb(251, 241, 199) rgb(40, 38, 37) / None None";
      status_ellipsis = "rgb(251, 241, 199) rgb(40, 38, 37)  Bold / None None";
      purpose_normal = "None None";
      purpose_italic = "rgb(177, 98, 134) None Italic";
      purpose_bold = "rgb(177, 98, 134) None Bold";
      purpose_ellipsis = "None None";
      scrollbar_track = "rgb(80, 73, 69) None / rgb(50, 48, 47) None";
      scrollbar_thumb = "rgb(213, 196, 161) None / rgb(102, 92, 84) None";
      help_paragraph = "None None";
      help_bold = "rgb(214, 93, 14) None Bold";
      help_italic = "rgb(211, 134, 155) None Italic";
      help_code = "rgb(142, 192, 124) rgb(50, 48, 47)";
      help_headers = "rgb(254, 128, 25) None Bold";
      help_table_border = "rgb(80, 73, 69) None";
      preview_title = "rgb(235, 219, 178) rgb(40, 40, 40) / rgb(189, 174, 147) rgb(40, 40, 40)";
      preview = "rgb(235, 219, 178) rgb(40, 40, 40) / rgb(235, 219, 178) rgb(40, 40, 40)";
      preview_line_number = "rgb(124, 111, 100) None / rgb(124, 111, 100) rgb(40, 40, 40)";
      preview_match = "None ansi(29) Bold";
      hex_null = "rgb(189, 174, 147) None";
      hex_ascii_graphic = "rgb(213, 196, 161) None";
      hex_ascii_whitespace = "rgb(152, 151, 26) None";
      hex_ascii_other = "rgb(254, 128, 25) None";
      hex_non_ascii = "rgb(214, 93, 14) None";
      staging_area_title = "rgb(235, 219, 178) rgb(40, 40, 40) / rgb(189, 174, 147) rgb(40, 40, 40)";
      mode_command_mark = "gray(5) ansi(204) Bold";
    };
  };
}
