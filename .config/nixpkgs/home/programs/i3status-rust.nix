{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.i3status-rust;
  sysCfg = config.passthru.systemConfig or null;
in {
  options       .programs.i3status-rust.enable = lib.mkEnableOption "i3status-rust";
  options.config.programs.i3status-rust = with lib; {
    enable = mkOption {
      type = types.bool;
      default = config.programs.i3status-rust.enable;
      defaultText = "<option>config.programs.i3status-rust.enable</option>";
      description = "Whether to configure i3status-rust.";
    };

    data = mkEnableOption "user's data root.";

    configFile = mkOption {
      type = types.path;
      default = config.home.homeDirectory + "/" + config.xdg.configFile."i3/status.toml".target;
      readOnly = true;
    };
  };

  config = lib.mkMerge [
    { home.packages = lib.optional config.programs.i3status-rust.enable pkgs.i3status-rust; }

    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [ font-awesome_5 ];

      xdg.configFile."i3/status.toml".text = ''
        icons = "awesome"

        [theme]
        name = "slick"

        [theme.overrides]
        separator = ""

        [[block]]
        block = "disk_space"
        info_type = "available"
        warning = 25
        alert = 10
        show_percentage = true
      '' + (lib.optionalString (cfg.data && sysCfg.config.data.enable or false) ''
        [[block]]
        block = "disk_space"
        alias = "data"
        path = "${sysCfg.config.data.mountPoint}${lib.optionalString sysCfg.config.data.userFileSystems "/${builtins.getEnv "USER"}"}"
      '') + ''
        [[block]]
        block = "nvidia_gpu"

        [[block]]
        block = "memory"
        format_mem = "{Mupi}% {MAg}G"
        format_swap = "{SUpi}% {SFg}G"

        [[block]]
        block = "temperature"
        format = "⌀{average}° ↑{max}°"

        [[block]]
        block = "load"

        [[block]]
        block = "battery"
        device = "BAT1"
        format = "{percentage}% {time} {power}"

        [[block]]
        block = "time"
        interval = 1
        format = "%m-%d %H:%M:%S"
      '';
    })
  ];
}
