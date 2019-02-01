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

    batteries = with lib; mkOption {
      type = with types; listOf str;
      default = if !pkgs.stdenv.isLinux then [] else
        filter (hasPrefix "BAT") (builtins.attrNames (builtins.readDir /sys/class/power_supply));
    };

    configFile = mkOption {
      type = types.path;
      default = config.home.homeDirectory + "/" + config.xdg.configFile."i3/status.toml".target;
      readOnly = true;
    };
  };

  config = lib.mkMerge [
    { home.packages = lib.optional config.programs.i3status-rust.enable pkgs.i3status-rust; }

    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        font-awesome_5
        lm_sensors
      ];

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
      '' + lib.optionalString (cfg.data && sysCfg.config.data.enable or false) ''
        [[block]]
        block = "disk_space"
        alias = "data"
        path = "${sysCfg.config.data.mountPoint}${lib.optionalString sysCfg.config.data.userFileSystems "/${builtins.getEnv "USER"}"}"
      '' + lib.optionalString (builtins.any (lib.hasPrefix "nvidia") sysCfg.services.xserver.videoDrivers) ''
        [[block]]
        block = "nvidia_gpu"
      '' + ''
        [[block]]
        block = "memory"
        format_mem = "{Mupi}% {MAg}G"
        format_swap = "{SUpi}% {SFg}G"

        [[block]]
        block = "temperature"
        format = "⌀{average}° ↑{max}°"

        [[block]]
        block = "load"
      '' + lib.concatStrings (map (battery: ''
        [[block]]
        block = "battery"
        device = "${battery}"
        format = "{percentage}% {time} {power}"
      '') cfg.batteries) + ''
        [[block]]
        block = "time"
        interval = 1
        format = "%b %m-%d %a %H:%M:%S"
      '';
    })
  ];
}
