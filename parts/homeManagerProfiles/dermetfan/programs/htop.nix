{ config, ... }:

{
  programs.htop.settings = {
    hide_userland_threads = true;
    show_program_path = false;
    tree_view = true;
  } // (with config.lib.htop;
    (leftMeters [
      (bar "LeftCPUs")
      (bar "Memory")
      (bar "Swap")
    ]) //
    (rightMeters [
      (bar "RightCPUs")
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
    ])
  );
}
