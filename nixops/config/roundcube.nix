{ config, lib, pkgs, ... }:

let
  cfg = config.services.roundcube;
in {
  options.services.roundcube = with lib; {
    enigma.pgpHomedir = mkOption {
      type = types.path;
      default = "/var/lib/roundcube/enigma";
    };

    config = mkOption {
      type = types.attrs;
      default = {
        default_host = {
          "ssl://imap.gmail.com:993" = "Gmail";
          "ssl://imap.inf.h-brs.de:993" = "H-BRS FB Informatik";
        };

        smtp_server = {
          "imap.gmail.com" = "ssl://smtp.%z:465";
          "imap.inf.h-brs.de" = "tls://smtp.%z:587";
        };
        smtp_user = "%u";
        smtp_pass = "%p";

        draft_autosave = 60;
        reply_mode = -1;
        sig_separator = false;

        newmail_notifier_sound = true;
        newmail_notifier_desktop = true;
        newmail_notifier_desktop_timeout = 5;

        enigma_pgp_homedir = cfg.enigma.pgpHomedir;
        enigma_pgp_binary = pkgs.gnupg + "/bin/gpg";
        enigma_pgp_agent = pkgs.gnupg + "/bin/gpg-agent";
        enigma_pgp_gpgconf = pkgs.gnupg + "/bin/gpgconf";
        enigma_passwordless = true;

        keyservers = ["keys.openpgp.org" "pgp.mit.edu" "pgp.key-server.io"];
      };
    };
  };

  config.services = lib.mkIf cfg.enable {
    roundcube = {
      package = pkgs.roundcube.withPlugins (plugins: with plugins; [
        persistent_login
        carddav
      ]);

      plugins = [
        "persistent_login"
        "carddav"
        "enigma"
        "attachment_reminder"
        "vcard_attachments"
        "zipdownload"
      ];

      hostName = "roundcube." + config.passthru.domain;

      extraConfig = config.passthru.lib.generators.toPHP { variable = "config"; } cfg.config;
    };

    nginx.virtualHosts.${config.services.roundcube.hostName} = config.passthru."nginx.virtualHosts.withSSL" {};
  };
}
