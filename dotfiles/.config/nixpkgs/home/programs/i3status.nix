{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.i3status;
  sysCfg = config.passthru.systemConfig or null;
  data = "${sysCfg.config.data.mountPoint}/${config.home.username}";
in {
  options.config.programs.i3status.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.i3status.enable;
    defaultText = "<option>config.programs.i3status.enable</option>";
    description = "Whether to configure i3status.";
  };

  # TODO use home-manager module options now that it exists
  config.xdg.configFile = lib.mkIf cfg.enable {
    "i3status/config".text = ''
      general {
          colors = true
          color_separator = "#55b5e7"
      }

      ${lib.optionalString (sysCfg != null)
        ''order += "disk ${data}"''
      }
      order += "disk /"
      #order += "ethernet _first_"
      #order += "wireless _first_"
      order += "cpu_temperature 0"
      order += "battery all"
      #order += "volume master"
      order += "time"

      time {
          format = "%m-%d %H:%M:%S "
      }

      volume master {}

      battery all {
          format = "%percentage %status %remaining %consumption"
          integer_battery_capacity = true
          low_threshold = 15
          threshold_type = time
      }

      cpu_temperature 0 {
          format = "CPU: %degrees°C"
          max_threshold = "90"
      }

      wireless _first_ {}

      ethernet _first_ {}

      ${lib.optionalString (sysCfg != null) ''
          disk "${data}" {
              format = "data: %free (%percentage_used)"
              low_threshold = 10
              threshold_type = percentage_free
          }
        ''
      }

      disk "/" {
          format = "%free (%percentage_used)"
          low_threshold = 25
          threshold_type = percentage_free
      }
    '';
  };
}
