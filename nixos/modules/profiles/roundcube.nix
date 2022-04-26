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
      (pkgs.roundcubePlugins.roundcubePlugin {
        pname = "multi_smtp";
        version = "0.0.0";
        src = pkgs.fetchgit {
          # if Gist goes down recover source from commit 68fe1bc
          url = https://gist.github.com/kimbtech/b6b08f1778420766ee1a2d24117d4871;
          rev = "7453877ddc3fbe6529d14d9a246285702abd9ca8";
          sha256 = "1q3dcqagyyvrskkw2bh5dl2kx643jzw5n67c7gs7mylq18wfh4sj";
        };
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
