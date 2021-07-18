{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.htop;
in {
  options.config.programs.htop.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.htop.enable;
    defaultText = "<option>programs.htop.enable</option>";
    description = "Whether to configure htop.";
  };

  config.programs.htop = lib.mkIf cfg.enable {
    settings = {
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
  };
}
