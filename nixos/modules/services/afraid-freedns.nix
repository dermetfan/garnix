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

    ip4TokensFile = mkOption {
      type = with types; nullOr path;
      default = null;
    };

    ip6TokensFile = mkOption {
      type = with types; nullOr path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ {
      assertion = cfg.ip4TokensFile != null || cfg.ip6TokensFile != null;
      message = "Neither a token for IPv4 nor IPv6 is given.";
    } ];

    systemd = {
      services.afraid-freedns = {
        inherit description;
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          LoadCredential = with cfg;
            (lib.optional (ip4TokensFile != null) "ip4-tokens:${ip4TokensFile}") ++
            (lib.optional (ip6TokensFile != null) "ip6-tokens:${ip6TokensFile}");
        };
        path = with pkgs; [ curl ];
        script = let
          curlCmd = "curl -sS";
        in ''
          if [[ -f $CREDENTIALS_DIRECTORY/ip4-tokens ]]; then
            while read token; do
              ${curlCmd} "https://sync.afraid.org/u/$token/"
            done < $CREDENTIALS_DIRECTORY/ip4-tokens
          fi

          if [[ -f $CREDENTIALS_DIRECTORY/ip6-tokens ]]; then
            while read token; do
              ${curlCmd} "https://v6.sync.afraid.org/u/$token/"
            done < $CREDENTIALS_DIRECTORY/ip6-tokens
          fi
        '';
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
  };
}
