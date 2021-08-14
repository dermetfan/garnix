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

    barConfigFiles = mkOption {
      type = with types; attrsOf path;
      default = mapAttrs (k: v:
        config.home.homeDirectory + "/" + config.xdg.configFile."i3status-rust/config-${k}.toml".target
      ) config.programs.i3status-rust.bars;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      powerline-fonts
      font-awesome
      lm_sensors
    ];

    programs.i3status-rust.bars.default = let
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
    in {
      icons = "awesome5";
      theme = "gruvbox-dark";

      blocks = [
        {
          block = "disk_space";
          format = "{icon} {path} {percentage} {free}";
          info_type = "used";
          warning = 75;
          alert = 90;
        }
      ] ++ lib.optional (cfg.data && sysCfg.config.data.enable or false) {
        block = "disk_space";
        alias = "data";
        path = "${sysCfg.config.data.mountPoint}${lib.optionalString sysCfg.config.data.userFileSystems "/${builtins.getEnv "USER"}"}";
      } ++ lib.optional (builtins.any (lib.hasPrefix "nvidia") sysCfg.services.xserver.videoDrivers) {
        block = "nvidia_gpu";
      } ++ [
        {
          block = "memory";
          format_mem = "{mem_used_percents} {mem_avail;G}";
          format_swap = "{swap_used_percents} {swap_free;G}";
        }
        {
          block = "temperature";
          format = "⌀{average}C ↑{max}C";
        }
        { block = "load"; }
      ] ++ (
        map (battery: {
          block = "battery";
          device = battery;
          format = "{percentage} {time} {power}";
        }) cfg.batteries
      ) ++ [
        {
          block = "toggle";
          text = "eco";
          command_on = "${eco} on";
          command_off = "${eco} off";
          command_state = "${eco}";
        }
        {
          block = "time";
          interval = 1;
          format = "%b %m-%d %a %H:%M:%S";
        }
      ];
    };
  };
}
