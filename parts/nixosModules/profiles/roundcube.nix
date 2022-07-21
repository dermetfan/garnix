_:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.roundcube;
in {
  options.profiles.roundcube.enable = lib.mkEnableOption "roundcube";

  config.services.roundcube = lib.mkIf cfg.enable {
    enable = true;

    hostName = "roundcube.${config.networking.domain}";

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

    settings = {
      default_host = lib.mkOptionDefault {
        "ssl://imap.inf.h-brs.de:993" = "H-BRS FB02 Informatik";
        "ssl://owa.stud.h-brs.de:993" = "H-BRS FB06 Sozialpolitik und Soziale Sicherung";
      };

      smtp_server = lib.mkOptionDefault {
        "imap.inf.h-brs.de" = "tls://smtp.%z:587";
        "owa.stud.h-brs.de" = "tls://owa.stud.h-brs.de:587";
      };
    };
  };
}
