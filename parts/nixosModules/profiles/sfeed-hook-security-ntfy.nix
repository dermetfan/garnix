_:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.sfeed-hook-security-ntfy;
in {
  options.profiles.sfeed-hook-security-ntfy = {
    enable = lib.mkEnableOption "sfeed-hook-security-ntfy";

    topic = lib.mkOption {
      type = lib.types.str;
      default = "security";
      example = "https://ntfy.example.com/security";
      description = ''
        Topic URL passed to the ntfy CLI.
      '';
    };

    ntfyUsername = lib.mkOption {
      type = lib.types.str;
      description = ''
        Which user's first token to grab from `$NTFY_AUTH_TOKENS`
        which is expected to come from {option}`services.ntfy-sh.environmentFile`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.singleton {
      assertion = config.services.ntfy-sh.environmentFile != null;
      message = ''
        `profiles.sfeed-hook-security-ntfy` expects to get its `NTFY_AUTH_TOKENS` env var
        from `services.ntfy-sh.environmentFile`, but it is null.
        This limitation could be lifted by adding an option for a token file,
        but this is currently not implemented.
      '';
    };

    services.sfeed-hook.security-ntfy = {
      feeds = {
        sans-isc = "https://isc.sans.edu/rssfeed.xml";
        cert-eu = "https://www.cert.europa.eu/publications/security-advisories-rss";
        # cisa-us = "https://www.cisa.gov/cybersecurity-advisories/ics-advisories.xml"; # apparently blocks some datacenter IPs
        # cyber-au = "https://www.cyber.gov.au/rss/alerts"; # fails to fetch for some reason
        tldrcve = "https://tldrcve.com/feed.xml";
        # For product-specific alerts: https://assurestart.co/cve-rss-feeds#builder
      };
      hook = pkgs.writers.writeNu "security-ntfy.nu" ''
        if $env.RSS_FEED == sans-isc {
          if (
            [
              https://isc.sans.edu/infocon.txt
              https://www.dshield.org/infocon.txt
            ] | all {
              let infocon = try {http get --raw $in}
              $infocon == green
            }
          ) {
            print --stderr $"Infocon is green, skipping ($env.RSS_FEED): ($env.RSS_ID)"
            return
          }
        }

        (
          ${lib.getExe pkgs.ntfy-sh} publish
          --token (
            $env.NTFY_AUTH_TOKENS
            | split row ,
            | split column : user token label
            | where user == dermetfan
            | first
            | get token
          )
          --title $"Security Advisory \(($env.RSS_FEED)\)"
          --priority 4
          --tags warning
          --click $env.RSS_LINK
          ${lib.toJSON cfg.topic}
          $env.RSS_TITLE
        )
      '';
    };

    systemd.services.sfeed-hook-security-ntfy.serviceConfig.EnvironmentFile = config.services.ntfy-sh.environmentFile;
  };
}
