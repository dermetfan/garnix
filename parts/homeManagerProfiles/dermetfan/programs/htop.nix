{ config, ... }:

{
  programs.htop.settings = {
    hide_userland_threads = true;
    hide_kernel_threads = true;
    show_thread_names = true;
    show_program_path = false;
    show_merged_command = true;
    header_margin = false;
    screen_tabs = true;
    tree_view = true;
    cpu_count_from_one = true;
    show_cpu_frequency = true;
    show_cpu_temperature = true;
    fields = with config.lib.htop.fields; [
      PID
      USER
      PRIORITY
      NICE
      M_SWAP
      M_SIZE
      M_RESIDENT
      M_SHARE
      STATE
      PERCENT_CPU
      PERCENT_MEM
      TIME
      COMM
    ];
  } // (with config.lib.htop;
    (leftMeters [
      (bar "AllCPUs2")
      (bar "MemorySwap")
      (bar "Zram")
    ]) //
    (rightMeters [
      (bar "ZFSARC")
      (text "DiskIO")
      (text "NetworkIO")
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
    ])
  );
}
