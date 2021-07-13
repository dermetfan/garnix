{ config, lib, pkgs, ... }:

let
  cfg = config.services.roundcube;
in {
  options.services.roundcube = with lib; {
    enigma.pgpHomedir = mkOption {
      type = types.path;
      default = "/var/lib/roundcube/enigma";
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

      extraConfig = ''
        $config['default_host'] = [
          'ssl://imap.gmail.com:993' => 'Gmail',
        ];

        $config['smtp_server'] = 'ssl://smtp.%z:465';
        $config['smtp_user'] = '%u';
        $config['smtp_pass'] = '%p';

        $config['draft_autosave'] = 60;
        $config['reply_mode'] = -1;
        $config['sig_separator'] = false;

        $config['newmail_notifier_sound'] = true;
        $config['newmail_notifier_desktop'] = true;
        $config['newmail_notifier_desktop_timeout'] = 5;

        $config['enigma_pgp_homedir'] = ${lib.escapeShellArg cfg.enigma.pgpHomedir};
        $config['enigma_pgp_binary'] = ${lib.escapeShellArg "${pkgs.gnupg}/bin/gpg"};
        $config['enigma_pgp_agent'] = ${lib.escapeShellArg "${pkgs.gnupg}/bin/gpg-agent"};
        $config['enigma_pgp_gpgconf'] = ${lib.escapeShellArg "${pkgs.gnupg}/bin/gpgconf"};
        $config['enigma_passwordless'] = true;

        $config['keyservers'] = ['keys.openpgp.org', 'pgp.mit.edu', 'pgp.key-server.io'];
      '';
    };

    nginx.virtualHosts.${config.services.roundcube.hostName} = config.passthru."nginx.virtualHosts.withSSL" {};
  };
}
