{ config, lib, pkgs, ... }:

{
  services = {
    roundcube = {
      package = pkgs.roundcube.withPlugins (plugins: with plugins; [
        persistent_login
      ]);

      plugins = [ "persistent_login" ];

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
      '';
    };

    nginx = lib.mkIf config.services.roundcube.enable {
      virtualHosts.${config.services.roundcube.hostName} = config.passthru."nginx.virtualHosts.withSSL" {};
    };
  };
}
