{ nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.i3status-rust;
in {
  options.profiles.dermetfan.programs.i3status-rust = with lib; {
    enable = mkEnableOption "i3status-rust" // {
      default = config.programs.i3status-rust.enable;
    };

    enableEco = mkOption {
      type = types.bool;
      default = true;
      description = ''
        The i3status-rust "eco" block requires cpupower to be usable without password through sudo.
        Please put this in your NixOS config if necessary:

        <code>
        security.sudo.extraRules = lib.mkAfter [
          {
            commands = [ {
              command = "''${pkgs.linuxPackages.cpupower}/bin/cpupower";
              options = [ "NOPASSWD" ];
            } ];
            groups = [ config.users.groups.wheel.gid ];
          }
        ];
        </code>
      '';
    };

    batteries = mkOption {
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

  config = {
    home.packages = with pkgs; [
      powerline-fonts
      font-awesome
      lm_sensors
    ];

    programs.i3status-rust.bars.default = rec {
      icons = "awesome5";
      theme = "gruvbox-dark";

      blocks = let
        disk_space = {
          block = "disk_space";
          format = "{icon} {path} {percentage} {free}";
          info_type = "used";
          warning = 75;
          alert = 90;
        };
      in [
        disk_space
      ] ++ lib.optional (builtins.any (lib.hasPrefix "nvidia") nixosConfig.services.xserver.videoDrivers or []) {
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
      ) ++ lib.optional cfg.enableEco (let
        eco = pkgs.writeScript "eco.sh" ''
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
        block = "toggle";
        text = "eco";
        command_on = "${eco} on";
        command_off = "${eco} off";
        command_state = "${eco}";
      }) ++ [
        {
          block = "time";
          interval = 1;
          format = "%b %m-%d %a %H:%M:%S";
        }
      ];
    };
  };
}
