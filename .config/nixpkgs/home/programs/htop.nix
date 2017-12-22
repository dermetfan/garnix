{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.htop;
in {
  options.config.programs.htop.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.htop.enable;
    defaultText = "<option>config.programs.htop.enable</option>";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.htop ];

      file.".config/htop/htoprc".text = ''
        # Beware! This file is rewritten by htop when settings are changed in the interface.
        # The parser is also very primitive, and not human-friendly.
        fields=0 48 17 18 38 39 40 2 46 47 49 1
        sort_key=46
        sort_direction=1
        hide_threads=0
        hide_kernel_threads=1
        hide_userland_threads=1
        shadow_other_users=0
        show_thread_names=0
        show_program_path=0
        highlight_base_name=0
        highlight_megabytes=1
        highlight_threads=1
        tree_view=1
        header_margin=1
        detailed_cpu_time=0
        cpu_count_from_zero=0
        update_process_names=0
        account_guest_in_cpu_meter=0
        color_scheme=0
        delay=15
        left_meters=LeftCPUs Memory Swap
        left_meter_modes=1 1 1
        right_meters=RightCPUs Tasks LoadAverage Uptime
        right_meter_modes=1 2 2 2
      '';
    };
  };
}
