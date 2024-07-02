{ inputs, ... }:

{ nodes, config, lib, pkgs, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
    inputs.filestash.nixosModules.default
  ];

  system.stateVersion = "24.11";

  environment = {
    persistence."/state" = {
      files = map (key: key.path) config.services.openssh.hostKeys;
      directories = [
        "/var/lib/acme"
        config.services.postgresql.dataDir
        "/var/lib/authelia-${config.services.authelia.instances.default.name}"
      ];
    };

    systemPackages = with pkgs; [ bindfs ];
  };

  age = {
    # https://github.com/ryantm/agenix/issues/45
    identityPaths = map (key: "/state${toString key.path}") config.services.openssh.hostKeys;

    secrets = {
      authelia-default-users = {
        file = ../../../../secrets/services/authelia/users.json.age;
        owner = config.services.authelia.instances.default.user;
        group = config.services.authelia.instances.default.group;
      };

      authelia-default-storage = {
        file = ../../../../secrets/services/authelia/storage.age;
        owner = config.services.authelia.instances.default.user;
        group = config.services.authelia.instances.default.group;
      };

      authelia-default-jwt = {
        file = ../../../../secrets/services/authelia/jwt.age;
        owner = config.services.authelia.instances.default.user;
        group = config.services.authelia.instances.default.group;
      };

      roundcube-google-oauth2-client-secret = {
        file = ../../../../secrets/services/roundcube-google-oauth2-client-secret.age;
        owner = config.services.roundcube.database.username;
        group = config.services.roundcube.database.username;
      };

      filestash = {
        file = ../../../../secrets/services/filestash.age;
        owner = config.services.filestash.user;
        group = config.services.filestash.group;
      };
    };
  };

  profiles = {
    roundcube.enable = true;
    yggdrasil.enable = true;
    ntfy-sh.enable = true;
    users.users.dermetfan.enable = true;
    dev.enable = true;
  };

  programs.ssh.extraConfig = ''
    Host znapzend-node-0
      Hostname ${with nodes.node-0.config.networking; "${hostName}.hosts.${domain}"}
  '' + lib.concatMapStringsSep "\n" (key: "  IdentityFile ${key.path}") config.services.openssh.hostKeys + "\n" + ''
      User znapzend
      IdentitiesOnly yes
  '';

  services = {
    homepage.enable = true;

    webdav = {
      enable = true;

      settings = {
        address = "127.0.0.1";
        port = 4918;
        behindProxy = true;

        cors = {
          enabled = true;
          credentials = true;
          allowed_methods = [ "GET" ];
          exposed_headers = [
            "Content-Length"
            "Content-Range"
          ];
        };

        directory = "/var/empty";
        permissions = "CRUD";

        users = lib.mapAttrsToList
          (username: password: {
            inherit username password;
            directory = "/mnt/webdav/home/${username}";
          })
          {
            dermetfan = "{bcrypt}$2a$05$t73.WbNz16IN8Qe6GEoXneAEiMb8diJorYWtHVTgtX/xP5hBatItK";
            diemetfan = "{bcrypt}$2a$05$GAWTv9qxSJMUqye5kgNK9eqdYFoyKwC42xz6wUsoqmROcVugt4ZSC";
            mutmetfan = "{bcrypt}$2a$05$ReOWPjUxS4bx3w.UedyBEu37yNKdczXkcqw85dm1XgnN8GzE7VRd6";
          };
      };
    };

    filestash = {
      enable = true;
      settings = {
        general = {
          host = "filestash.${config.networking.domain}";
          port = 8334;
          secret_key_file = config.age.secrets.filestash.path;
          editor = "base";
          fork_button = false;
          upload_button = true;
          filepage_default_view = "list";
          filepage_default_sort = "type";
        };
        share.default_access = "viewer";
        features.api.enable = false;
        auth.admin = "$2a$05$gIqN0/EbKTkj5iyZHjOgwOD6/ppQkKPzszkYGXSLvCuYapHWiACHC";
        connections = map (username: {
          label = username;
          type = "webdav";
          url = with config.services.webdav.settings; "http://${address}:${toString port}";
          inherit username;
        }) [
          "dermetfan"
          "diemetfan"
          "mutmetfan"
        ];
      };
    };

    authelia = {
      instances.default = {
        enable = true;
        secrets = {
          storageEncryptionKeyFile = config.age.secrets.authelia-default-storage.path;
          jwtSecretFile = config.age.secrets.authelia-default-jwt.path;
        };
        settings = let
          stateDirectory = "/var/lib/authelia-default";
        in {
          # Define a subset of the default endpoints because we don't need them all.
          # https://www.authelia.com/reference/guides/proxy-authorization/#default-endpoints
          server = {
            address = "tcp://127.0.0.1:9091";
            endpoints.authz.auth-request = {
              implementation = "AuthRequest";
              authn_strategies = [
                {
                  name = "HeaderAuthorization";
                  schemes = [ "Basic" ];
                }
                { name = "CookieSession"; }
              ];
            };
          };

          theme = "auto";
          session.cookies = lib.singleton {
            inherit (config.networking) domain;
            authelia_url = "https://${config.services.authelia.nginx.virtualHosts.default.host}";
          };
          storage.local.path = "${stateDirectory}/db.sqlite3";
          notifier.filesystem.filename = "${stateDirectory}/notifications.txt";
          access_control.default_policy = "two_factor";
          authentication_backend.file = {
            search.email = true;
            inherit (config.age.secrets.authelia-default-users) path;
          };
        };
      };

      nginx = {
        enable = true;
        virtualHosts.default.host = "auth.${config.networking.domain}";
      };
    };

    nginx.virtualHosts = let
      extraConfig = ''
        client_max_body_size 5G;
        proxy_request_buffering off;
      '';

      authelia = config.services.authelia.nginx.virtualHosts.default.protectLocation "/";
    in {
      ${config.services.authelia.nginx.virtualHosts.default.host}.enableACME = true;

      ${config.services.roundcube.hostName} = _: {
        imports = [
          # The Roundcube module sets a `Cache-Control` header on the `/` route
          # that interferes with Authelia so that it leads to a redirection loop.
          # Therefore we are not protecting `/`. We can do so because it only calls `/index.php` anyway.

          # this location is defined in the NixOS Roundcube module
          (config.services.authelia.nginx.virtualHosts.default.protectLocation "~* \\.php(/|$)")
        ];
      };

      "webdav.${config.networking.domain}" = _: {
        imports = [ authelia ];

        enableACME = true;
        forceSSL = true;

        locations."/".proxyPass = with config.services.webdav.settings; "http://${address}:${toString port}";

        inherit extraConfig;
      };

      ${config.services.filestash.settings.general.host} = _: {
        imports = [
          authelia
          (config.services.authelia.nginx.virtualHosts.default.protectLocation "/api/session/auth")
        ];

        enableACME = true;
        forceSSL = true;

        locations = let
          location.proxyPass = "http://127.0.0.1:${toString config.services.filestash.settings.general.port}";
        in {
          # protected by authelia
          "/" = location;
          "/api/session/auth" = location;

          # all other locations are not protected by authelia
          # so we can list public prefixes here
          # see https://github.com/mickael-kerjean/filestash/blob/master/server/routes.go
          "/s/" = location;
          "/api/" = location;
          "/assets/" = location;
          "/favicon.ico" = location;
          "/sw_cache.js" = location;
          "/report" = location;
          "/about" = location;
          "/robots.txt" = location;
          "/manifest.json" = location;
          "/.well-known/security.txt" = location;
          "/healthz" = location;
          "/custom.css" = location;
          "/doc" = location;
          "/overrides/" = location;
        };

        inherit extraConfig;
      };
    };

    znapzend = {
      pure = true;
      features = {
        compressed = true;
        recvu = true;
        zfsGetType = true;
        skipIntermediates = true;
        oracleMode = true;
      };
      zetup = let
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
        planFew = "1week=>1day,1month=>1week";
        planMany = "1week=>1day,1hour=>15minutes,15minutes=>5minutes,1day=>1hour,1year=>1month,1month=>1week";
        destinations = attrs: {
          node-0 = {
            host = "znapzend-node-0";
          } // attrs;
        };
      in {
        "root/root" = {
          inherit timestampFormat recursive;
          plan = planFew;
        };
        "root/state" = {
          inherit timestampFormat recursive;
          plan = planMany;
        };
        "root/home" = {
          inherit timestampFormat recursive;
          plan = planMany;
        };
        "tank/home" = {
          inherit timestampFormat recursive;
          plan = planMany;
          destinations = destinations {
            dataset = "tank/home";
            plan = planMany;
          };
        };
        "tank/services" = {
          inherit timestampFormat recursive;
          plan = planFew;
          destinations = destinations {
            dataset = "tank/services";
            plan = planFew;
          };
        };
      };
    };

    yggdrasil.publicPeers.germany.enable = true;

    roundcube = {
      enableGoogleLogin = true;

      settings = {
        oauth_client_id = "911394111478-ttomv09cm1jvom5tun0ajk3e2likv1tl.apps.googleusercontent.com";
        oauth_client_secret = /. + config.age.secrets.roundcube-google-oauth2-client-secret.path;

        enigma_pgp_homedir = "/tank/services/roundcube/enigma";
      };
    };
  };

  home-manager.users.dermetfan = {
    home.stateVersion = "24.11";

    profiles.dermetfan.environments = {
      admin.enable = true;
      dev.enable = true;
      iog.enable = true;
    };
  };

  fileSystems."/mnt/webdav/home" = {
    fsType = "fuse.bindfs";
    device = "/tank/home";
    options = [
      "map=1000/webdav:@users/@webdav"
      "nofail"
    ];
  };

  boot = {
    zfs = {
      extraPools = [ "tank" ];

      unlockEncryptedPoolsViaSSH = {
        enable = true;
        hostKeys = [
          "${toString <secrets>}/hosts/node-3/initrd_ssh_host_ed25519_key"
        ];
      };
    };

    initrd = {
      network.ssh.port = 2222;

      postResumeCommands = lib.mkAfter ''
        zfs rollback -r root/root@blank
        zfs rollback -r root/home@blank
      '';
    };
  };
}
