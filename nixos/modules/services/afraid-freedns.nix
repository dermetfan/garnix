{ config, lib, pkgs, ... }:

let
  cfg = config.services.afraid-freedns;
  description = "DynDNS update (freedns.afraid.org)";
in {
  options.services.afraid-freedns = with lib; {
    enable = mkEnableOption description;

    interval = mkOption {
      type = types.str;
      default = "*-*-* *:00/10:00";
    };

    ip4Tokens = mkOption {
      type = with types; listOf str;
      default = [];
    };

    ip6Tokens = mkOption {
      type = with types; listOf str;
      default = [];
    };
  };

  config.systemd = lib.mkIf cfg.enable {
    services.afraid-freedns = {
      inherit description;
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
      };
      path = with pkgs; [ curl ];
      script =
        let curlCmd = "curl -sS"; in
        lib.concatMapStringsSep "\n" (token:
          "${curlCmd} 'https://sync.afraid.org/u/${token}/'"
        ) cfg.ip4Tokens +
        lib.concatMapStringsSep "\n" (token:
          "${curlCmd} 'https://v6.sync.afraid.org/u/${token}/'"
        ) cfg.ip6Tokens;
    };

    timers.afraid-freedns = {
      inherit description;
      timerConfig = {
        OnStartupSec = "1m";
        OnCalendar = cfg.interval;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
