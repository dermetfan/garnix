_:

{ config, lib, pkgs, ... }:

let
  serviceName = "sfeed-hook";
in {
  options.services.${serviceName} = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule (_: {
      options = {
        enable = lib.mkEnableOption "hook execution on new RSS articles" // {
          default = true;
        };

        feeds = lib.mkOption {
          type = with lib.types; attrsOf str;
          example.sans-isc = "https://isc.sans.edu/rssfeed.xml";
          description = "Map of path-safe feed names to RSS/Atom URLs.";
        };

        interval = lib.mkOption {
          type = lib.types.str;
          default = "1h";
          description = "Polling interval for the systemd timer.";
        };

        skipInitial = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Do nothing when a feed has no stored articles.
          '';
        };

        hook = lib.mkOption {
          type = lib.types.path;
          description = ''
            Executable to run per new matching article.
            Article fields are provided in `RSS_*` environment variables.
            Nonzero exit fails the service, causing the hook to be run again with the same input next time.
            Stderr is logged, stdout is discarded.
          '';
        };
      };
    }));
    default = {};
    description = "instances";
  };

  config = let
    cfg = config.services.${serviceName};

    instances = lib.filterAttrs (_: {enable, ...}: enable) cfg;

    mapInstances = f: lib.mapAttrs' (instanceName: instanceCfg: let
      instanceServiceName = serviceName + "-" + instanceName;
    in lib.nameValuePair instanceServiceName (f instanceName instanceServiceName instanceCfg)) instances;
  in {
    assertions = [
      {
        assertion = lib.all (instanceCfg: instanceCfg.feeds != {}) (lib.attrValues cfg);
        message = "`services.${serviceName}.<name>.feeds` must not be empty.";
      }
      {
        assertion = lib.all (instanceCfg:
          lib.all
          (name: lib.match "^[^/]+$" name != null)
          (lib.attrNames instanceCfg.feeds)
        ) (lib.attrValues cfg);
        message = "`services.${serviceName}.<name>.feeds` names must be path-safe.";
      }
    ];

    systemd = {
      services = mapInstances (instanceName: instanceServiceName: instanceCfg: {
        description = "Poll RSS feeds and run a hook for each new article";

        wants = [ "network-online.target" ];
        after = config.systemd.services.${instanceServiceName}.wants;

        path = with pkgs; [
          sfeed

          # Optional dependencies from https://codemadness.org/git/sfeed/file/README.html
          curl
          glibc.bin # for iconv
          findutils # for xargs
        ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = let
            filter = pkgs.writers.writeNu "sfeed-filter.nu" ''
              def main [
                sfeedpath: path
                feed: string
              ]: string -> nothing {
                let raw = $in

                let history = $sfeedpath
                  | path join $feed
                  | if ($in | path exists) {open --raw | articles}

                if ${lib.toJSON instanceCfg.skipInitial} and ($history | is-empty) {
                  print --stderr $'($feed) has empty history, skipping.'
                } else {
                  let history_keys = $history | each {article-key}

                  for article in (
                    $raw
                    | articles
                    | where {article-key | $in not-in $history_keys}
                  ) {
                    with-env (
                      $article
                      | insert feed $feed
                      | update timestamp {format date %s}
                      | update category {str join "\u{0}"}
                      | items {|k v| [$'RSS_($k | str upcase)' $v]}
                      | into record
                    ) {
                      run-external ${instanceCfg.hook} o> /dev/null
                    }
                  }
                }

                print --raw --no-newline $raw
              }

              def articles []: string -> list<record> {
                lines
                | where {is-not-empty}
                | (
                  split column "\t"
                  timestamp
                  title
                  link
                  content
                  content_type
                  id
                  author
                  enclosure
                  category
                )
                | update timestamp {into datetime --format %s --timezone UTC}
                | update category {split row '|'}
              }

              def article-key []: record -> string {
                let article = $in
                $article.id | default --empty $"($article.title)\u{0}($article.timestamp)"
              }
            '';
          in
            "${pkgs.sfeed}/bin/sfeed_update " +
            pkgs.writeScript "${instanceServiceName}-sfeedrc" ''
              sfeedpath=$STATE_DIRECTORY

              feeds() {
                ${
                  lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (name: url:
                      "feed ${lib.escapeShellArg name} ${lib.escapeShellArg url}"
                    ) instanceCfg.feeds
                  )
                }
              }

              filter() {
                ${lib.getExe pkgs.nushell} --no-config-file --stdin ${filter} "$sfeedpath" "$1"
              }
            '';
          DynamicUser = true;
          StateDirectory = "${serviceName}/${instanceName}";
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          NoNewPrivileges = true;
        };
      });

      timers = mapInstances (_: _: instanceCfg: {
        description = "Run a hook on new RSS articles";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnActiveSec = 0;
          OnUnitActiveSec = instanceCfg.interval;
          RandomizedDelaySec = 30;
        };
      });
    };
  };
}
