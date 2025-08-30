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
        The i3status-rust "eco" block requires tlp to be usable without password through sudo.
        Please put this in your NixOS config if necessary:

        <code>
        security.sudo.extraRules = lib.mkAfter [
          {
            commands = [ {
              command = lib.getExe config.services.tlp.package;
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
      description = ''
        Battery names.
        These can be found by matching:
        /sys/class/power_supply/BAT*
      '';
      default = [];
    };

    barConfigFiles = mkOption {
      type = with types; attrsOf path;
      default = optionalAttrs cfg.enable (
        mapAttrs (k: v:
          config.home.homeDirectory + "/" + config.xdg.configFile."i3status-rust/config-${k}.toml".target
        ) config.programs.i3status-rust.bars
      );
      readOnly = true;
    };
  };

  config = {
    home.packages = with pkgs; [
      powerline-fonts
      font-awesome
      lm_sensors
    ];

    programs.i3status-rust.bars.default = {
      icons = "awesome5";
      theme = "gruvbox-dark";

      blocks = let
        disk_space = {
          block = "disk_space";
          format = " $icon $path $percentage $available ";
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
          format = " $icon $mem_used_percents.eng(w:1) $mem_avail.eng(p:Gi) ";
          format_alt = " $icon_swap $swap_used_percents.eng(w:1) $swap_free.eng(p:Gi) ";
        }
        {
          block = "temperature";
          format = " $icon ⌀{$average}C ↑{$max}C ";
        }
        { block = "load"; }
      ] ++ (
        map (device: rec {
          block = "battery";
          inherit device;
          format = charging_format;
          charging_format = "${not_charging_format}{$time_remaining.duration(hms:true, min_unit:m) |}";
          not_charging_format = " $icon $percentage {$power |}";
          missing_format = " $icon missing ";
          full_format = charging_format;
          empty_format = charging_format;
        }) cfg.batteries
      ) ++ lib.optional cfg.enableEco (let
        eco =
          assert nixosConfig.security.sudo.enable or true;
          assert nixosConfig.services.tlp.enable or true;
          pkgs.writeShellApplication {
            name = "eco.sh";
            text = ''
              case "''${1:-}" in
                on)
                  ${lib.optionalString config.xsession.enable "systemctl --user stop picom"}
                  sudo ${lib.getExe nixosConfig.services.tlp.package} bat
                  ;;
                off)
                  ${lib.optionalString config.xsession.enable "systemctl --user start picom"}
                  sudo ${lib.getExe nixosConfig.services.tlp.package} ac
                  ;;
                *)
                  mode=$(tlp-stat --mode)
                  if [[ "$mode" = battery* ]]; then
                    echo yes
                  fi
                  ;;
              esac
            '';
          };
      in {
        block = "toggle";
        format = " $icon eco ";
        command_on = "${lib.getExe eco} on";
        command_off = "${lib.getExe eco} off";
        command_state = lib.getExe eco;
      }) ++ [
        {
          block = "time";
          interval = 1;
          format = " $icon $timestamp.datetime(f:'%b %m-%d %a %H:%M:%S') ";
        }
      ];
    };
  };
}
