{ config, lib, pkgs, ... }:

let
  cfg = config.services.roundcube;
in {
  options.services.roundcube.config = with lib; mkOption {
    type = with types; submodule {
      freeformType = attrsOf (oneOf [ bool int str (listOf str) (attrsOf str)]);
      options = {
        default_host = mkOption {
          type = oneOf [ str (listOf str) (attrsOf str) ];
          default."ssl://imap.gmail.com:993" = "Gmail";
        };

        smtp_server = mkOption {
          type = oneOf [ str (listOf str) (attrsOf str) ];
          default."imap.gmail.com" = "ssl://smtp.%z:465";
        };

        smtp_user = mkOption {
          type = str;
          default = "%u";
        };

        smtp_pass = mkOption {
          type = str;
          default = "%p";
        };

        draft_autosave = mkOption {
          type = int;
          default = 60;
        };

        reply_mode = mkOption {
          type = int;
          default = -1;
        };

        sig_separator = mkOption {
          type = bool;
          default = false;
        };

        newmail_notifier_sound = mkOption {
          type = bool;
          default = true;
        };

        newmail_notifier_desktop = mkOption {
          type = bool;
          default = true;
        };

        newmail_notifier_desktop_timeout = mkOption {
          type = int;
          default = 5;
        };

        enigma_pgp_homedir = mkOption {
          type = path;
          default = "/var/lib/roundcube/enigma";
        };

        enigma_pgp_binary = mkOption {
          type = path;
          default = pkgs.gnupg + "/bin/gpg";
        };

        enigma_pgp_agent = mkOption {
          type = path;
          default = pkgs.gnupg + "/bin/gpg-agent";
        };

        enigma_pgp_gpgconf = mkOption {
          type = path;
          default = pkgs.gnupg + "/bin/gpgconf";
        };

        enigma_passwordless = mkOption {
          type = bool;
          default = true;
        };

        keyservers = mkOption {
          type = listOf str;
          default = [ "keys.openpgp.org" "pgp.mit.edu" "pgp.key-server.io" ];
        };
      };
    };
  };

  config.services = lib.mkIf cfg.enable {
    roundcube = {
      package = pkgs.roundcube.withPlugins (plugins: with plugins; [
        persistent_login
        carddav
        (pkgs.roundcubePlugins.roundcubePlugin {
          pname = "multi_smtp";
          version = "0.0.0";
          src = roundcube/multi_smtp;
        })
      ]);

      plugins = [
        "persistent_login"
        "carddav"
        "enigma"
        "attachment_reminder"
        "vcard_attachments"
        "zipdownload"
        "multi_smtp"
      ];

      hostName = "roundcube." + config.passthru.domain;

      config = {
        default_host = lib.mkOptionDefault {
          "ssl://imap.inf.h-brs.de:993" = "H-BRS FB02 Informatik";
          "ssl://owa.stud.h-brs.de:993" = "H-BRS FB06 Sozialpolitik und Soziale Sicherung";
        };

        smtp_server = lib.mkOptionDefault {
          "imap.inf.h-brs.de" = "tls://smtp.%z:587";
          "owa.stud.h-brs.de" = "tls://owa.stud.h-brs.de:587";
        };
      };

      extraConfig = config.passthru.lib.generators.toPHP { variable = "config"; } cfg.config;
    };

    nginx.virtualHosts.${config.services.roundcube.hostName} = config.passthru."nginx.virtualHosts.withSSL" {};
  };
}
