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
    hideUserlandThreads = true;
    showProgramPath = false;
    treeView = true;
    meters = {
      left = [
        "LeftCPUs"
        "Memory"
        "Swap"
      ];
      right = [
        "RightCPUs"
        "Tasks"
        "LoadAverage"
        "Uptime"
      ];
    };
  };
}
