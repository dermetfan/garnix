{ config, ... }:

{
  programs.swappy.settings.Default = {
    save_dir = config.xdg.userDirs.pictures;
    save_filename_format = "swappy-%Y%m%d-%H%M%S.png";
    show_panel = true;
    line_size = 5;
    text_size = 20;
    text_font = "sans-serif";
    paint_mode = "rectangle";
    auto_save = false;
  };
}
