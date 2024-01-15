_:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.roundcube;
in {
  options.services.roundcube = with lib; {
    settings = mkOption {
      type = with types; submodule {
        freeformType = attrsOf (oneOf [
          bool int str path
          (listOf str) (attrsOf str)
          (listOf path) (attrsOf path)
        ]);
        options = {
          imap_host = mkOption {
            type = oneOf [ str (listOf str) (attrsOf str) ];
            default."ssl://imap.gmail.com:993" = "Gmail";
          };

          smtp_host = mkOption {
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

    enableGoogleLogin = mkEnableOption "Google OAuth2 login";
  };

  config.services.roundcube = lib.mkIf cfg.enable {
    extraConfig = (lib.generators.toPHP { variable = "config"; } cfg.settings);

    settings = lib.mkIf cfg.enableGoogleLogin {
      oauth_provider = "gmail";
      oauth_provider_name = "Google";
      oauth_auth_uri = "https://accounts.google.com/o/oauth2/auth";
      oauth_token_uri = "https://oauth2.googleapis.com/token";
      oauth_identity_uri = "https://www.googleapis.com/oauth2/v1/userinfo";
      oauth_scope = "email profile openid https://mail.google.com/";
      oauth_auth_parameters = {
        access_type = "offline";
        prompt = "consent";
      };
    };
  };
}
