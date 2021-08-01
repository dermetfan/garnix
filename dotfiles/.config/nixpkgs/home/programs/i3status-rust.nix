{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.i3status-rust;
  sysCfg = config.passthru.systemConfig or null;
in {
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
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        font-awesome_5
        lm_sensors
      ];

      # TODO use home-manager's i3status-rust options instead
      xdg.configFile."i3/status.toml".text = let
        eco = builtins.trace
          ''
            The i3status-rust "eco" block requires cpupower to be usable without password through sudo.
            Please put this in your NixOS config if necessary:

            security.sudo.extraRules = lib.mkAfter [
              {
                commands = [ {
                  command = "''${pkgs.linuxPackages.cpupower}/bin/cpupower";
                  options = [ "NOPASSWD" ];
                } ];
                groups = [ config.users.groups.wheel.gid ];
              }
            ];
          ''
          pkgs.writeScript "eco.sh" ''
            #! ${pkgs.bash}/bin/bash
            # XXX should this be a script provided by the system config with sudo rights?
            case "$1" in
                on)
                    ${lib.optionalString config.xsession.enable "systemctl --user stop picom"}
                    sudo cpupower frequency-set -g powersave
                    ;;
                off)
                    ${lib.optionalString config.xsession.enable "systemctl --user start picom"}
                    sudo cpupower frequency-set -g performance
                    ;;
            esac
          '';
      in ''
        icons = "awesome"

        [theme]
        name = "slick"

        [theme.overrides]
        separator = ""

        [[block]]
        block = "disk_space"
        format = "{icon} {path} {percentage} {free}"
        info_type = "used"
        warning = 75
        alert = 90
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
        format_mem = "{mem_used_percents} {mem_avail;G}"
        format_swap = "{swap_used_percents} {swap_free;G}"

        [[block]]
        block = "temperature"
        format = "⌀{average}C ↑{max}C"

        [[block]]
        block = "load"
      '' + lib.concatStrings (map (battery: ''
        [[block]]
        block = "battery"
        device = "${battery}"
        format = "{percentage} {time} {power}"
      '') cfg.batteries) + ''
        [[block]]
        block = "toggle"
        text = "eco"
        command_on = "${eco} on"
        command_off = "${eco} off"
        command_state = "${eco}"

        [[block]]
        block = "time"
        interval = 1
        format = "%b %m-%d %a %H:%M:%S"
      '';
    })
  ];
}
