{ inputs, ... }:

{ nodes, name, options, config, lib, pkgs, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
    inputs.copyparty.nixosModules.default
  ];

  nixpkgs.overlays = [
    inputs.copyparty.overlays.default
  ];

  system.stateVersion = "26.05";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "crush"
    "claude-code"
    "codex"
    "github-copilot-cli"
    "gemini-cli"
    "unrar"
  ];

  deployment.keys.ssh_host_key.destDir = lib.mkForce (config.environment.persistence."/state".persistentStoragePath + "/etc/ssh");

  environment = {
    persistence."/state" = {
      files = map (key: key.path) config.services.openssh.hostKeys;
      directories = [
        "/var/lib/nixos"
        "/var/lib/acme"
        config.services.postgresql.dataDir
        "/var/lib/authelia-${config.services.authelia.instances.default.name}"
        "/var/lib/copyparty"
        "/var/cache/copyparty"
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
        inherit (config.services.authelia.instances.default) group;
      };

      authelia-default-storage = {
        file = ../../../../secrets/services/authelia/storage.age;
        owner = config.services.authelia.instances.default.user;
        inherit (config.services.authelia.instances.default) group;
      };

      authelia-default-jwt = {
        file = ../../../../secrets/services/authelia/jwt.age;
        owner = config.services.authelia.instances.default.user;
        inherit (config.services.authelia.instances.default) group;
      };

      authelia-default-oidc-hmac = {
        file = ../../../../secrets/services/authelia/oidc-hmac.age;
        owner = config.services.authelia.instances.default.user;
        inherit (config.services.authelia.instances.default) group;
      };

      authelia-default-oidc-issuer = {
        file = ../../../../secrets/services/authelia/oidc-issuer.pem.age;
        owner = config.services.authelia.instances.default.user;
        inherit (config.services.authelia.instances.default) group;
      };

      roundcube-google-oauth2-client-secret = {
        file = ../../../../secrets/services/roundcube-google-oauth2-client-secret.age;
        owner = config.services.roundcube.database.username;
        group = config.services.roundcube.database.username;
      };
    };
  };

  profiles = {
    hardening.enable = true;
    roundcube.enable = true;
    yggdrasil.enable = true;
    ntfy-sh.enable = true;
    dawarich.enable = true;
    users.users.dermetfan.enable = true;
    dev.enable = true;
    iog.enable = true;
  };

  networking.firewall.allowedTCPPorts = with config.services.nginx; [
    defaultHTTPListenPort
    defaultSSLListenPort
  ];

  programs.ssh.extraConfig = ''
    Host znapzend-node-0
      Hostname ${with nodes.node-0.config.networking; "${hostName}.hosts.${domain}"}
  '' + lib.concatMapStringsSep "\n" (key: "  IdentityFile ${key.path}") config.services.openssh.hostKeys + "\n" + ''
      User znapzend
      IdentitiesOnly yes
  '';

  services = {
    homepage.enable = true;

    copyparty = {
      enable = true;

      package = pkgs.copyparty.override {
        withCertgen = false;
        withFastThumbnails = true; # https://github.com/9001/copyparty/issues/893#issuecomment-3368908300
        withFTP = false;
        withMagic = true;
      };

      settings = options.services.copyparty.settings.default // rec {
        i = [ "unix:770:/dev/shm/party.sock" ];
        s-tbody = 0;
        http-only = true;

        rproxy = 1;

        usernames = true;
        no-bauth = true;

        ah-alg = "argon2";

        idp-h-usr = config.services.authelia.nginx.virtualHosts.default.authenticatedHeaders.user;
        idp-h-grp = config.services.authelia.nginx.virtualHosts.default.authenticatedHeaders.groups;
        idp-gsep = ",";
        idp-h-key = "Shangala-Bangala";
        idp-store = 3;
        idp-adm = [ "@admin" ];

        no-robots = true;

        # j = 0; # implies `--no-fpool` which the help says is a bad idea on CoW filesystems
        ed = true;
        name = config.networking.domain;
        ver = true;

        e2d = true;
        no-hash =
          "/\\.("
          + builtins.concatStringsSep "|" [
            "git"
            "hg"
            "pijul"
            "direnv"
            "zig-cache"
            "gradle"
          ]
          + ")/";
        no-idx = no-hash;
        hash-mt = 8;
        dotsrch = true;

        e2ts = true;
        no-mutagen = true;

        xvol = true;
        logout = 168;

        stats = true;

        localtime = true;
        qdel = 1;
        spinner = "🌀,padding:0";
        nsort = true;

        shr = "/share";
        shr-adm = [ "@admin" ];

        chmod-f = toString 640;
        chmod-d = toString 750;

        # reflink = true; # README says "zfs had bugs"
        df = "256m";

        md-hist = "n";
        show-hist = true;

        nid = true;
      };

      globalExtraConfig = ''
        ipu: ${nodes.muttop.config.profiles.yggdrasil.ip}/128=mutmetfan
      '';

      volumes =
        {
          "/home/\${u}" = {
            path = "${config.fileSystems."/mnt/copyparty/home".mountPoint}/\${u}";
            access.A = [ "@admin" "\${u}" ];
            flags.daw = true;
          };
        }
        # Needed to avoid WebDAV errors with GVFS.
        // lib.genAttrs ["/" "/home"] (lib.const {
          path = "//NULL";
          access.r = "@acct";
          flags.d2d = true;
        });
    };

    authelia = {
      instances.default = {
        enable = true;
        secrets = {
          storageEncryptionKeyFile = config.age.secrets.authelia-default-storage.path;
          jwtSecretFile = config.age.secrets.authelia-default-jwt.path;
          oidcHmacSecretFile = config.age.secrets.authelia-default-oidc-hmac.path;
          oidcIssuerPrivateKeyFile = config.age.secrets.authelia-default-oidc-issuer.path;
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
            # https://www.authelia.com/reference/guides/passwords/#yaml-format
            inherit (config.age.secrets.authelia-default-users) path;
          };

          identity_providers.oidc.clients = [
            {
              client_name = "Dawarich";
              client_id = config.services.dawarich.environment.OIDC_CLIENT_ID;
              client_secret = "$pbkdf2-sha512$310000$VAgFkKhEe.01Elf7jCHhUQ$eJOmwwBHMwh/kGhXXV4x15sQt6r4YpuDk3Tmb74XRK5iIInilsy9WHVNrt47fp5AdE31K2PpmJSxK9TAdBHowg";
              redirect_uris = lib.singleton config.services.dawarich.environment.OIDC_REDIRECT_URI;
              scopes = [
                "openid"
                "email"
                "profile"
              ];
            }
          ];
        };
      };

      nginx = {
        enable = true;
        virtualHosts.default = {
          host = "auth.${config.networking.domain}";
          hardening.authDelay = "1s";
        };
      };
    };

    nginx = let
      # https://github.com/9001/copyparty/blob/hovudstraum/contrib/nginx/copyparty.conf
      copyparty = {
        upstream = {
          servers.${
            "unix:"
            + lib.pipe config.services.copyparty.settings.i [
              builtins.head
              (v: assert lib.hasPrefix "unix:" v; v)
              (lib.splitString ":")
              lib.last
            ]
          }.fail_timeout = "1s";

          extraConfig = ''
            keepalive 1;
          '';
        };

        virtualHost = {
          location.proxyPass = "http://copyparty";

          extraConfig = ''
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_buffers 32 8k;
            proxy_buffer_size 16k;
            proxy_busy_buffers_size 24k;
          '';
        };
      };
    in {
      upstreams.copyparty = copyparty.upstream;

      virtualHosts = let
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

        "files.${config.networking.domain}" = _: {
          imports = [ authelia ];

          enableACME = true;
          forceSSL = true;

          locations = {
            "/" = {
              inherit (copyparty.virtualHost.location) proxyPass;
              extraConfig = ''
                auth_request_set $idp_secret_header "yup";
                proxy_set_header ${config.services.copyparty.settings.idp-h-key} $idp_secret_header;
              '';
            };
          } // lib.genAttrs [
            "/.cpr/" # https://github.com/9001/copyparty/issues/84#issuecomment-2296785662
            "${lib.removeSuffix "/" config.services.copyparty.settings.shr}/"
          ] (_: { inherit (copyparty.virtualHost.location) proxyPass; });

          inherit (copyparty.virtualHost) extraConfig;
        };

        "files.ygg.${config.networking.domain}" = {
          listenAddresses = [ "[${config.profiles.yggdrasil.ip}]" ];

          locations."/" = { inherit (copyparty.virtualHost.location) proxyPass; };

          extraConfig = ''
            ${copyparty.virtualHost.extraConfig}

            # copyparty already does login by IP due to `--ipu`
            # but let's block everyone else entirely for good measure.
            allow ${nodes.muttop.config.profiles.yggdrasil.ip};
            deny all;
          '';
        };
      };
    };

    znapzend = {
      enable = true;
      features = {
        compressed = true;
        skipIntermediates = true;
      };
      zetup = let
        planFew = "1week=>1day,1month=>1week";
        planMany = "1week=>1day,1hour=>15minutes,15minutes=>5minutes,1day=>1hour,1year=>1month,1month=>1week";
        destinations = attrs: {
          node-0 = {
            host = "znapzend-node-0";
          } // attrs;
        };
      in lib.mapAttrs (k: v: {
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
      } // v) {
        "root/root".plan = planFew;
        "root/state".plan = planMany;
        "root/home".plan = planMany;
        "tank/home" = {
          plan = planMany;
          destinations = destinations {
            dataset = "tank/home";
            plan = planMany;
          };
        };
        "tank/services" = {
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

  systemd.services = {
    # Needed only because we use IdP syntax in the `volumes` option
    # and so it doesn't do this automatically like it usually would.
    copyparty.serviceConfig.BindPaths = [
      config.fileSystems."/mnt/copyparty/home".mountPoint
    ];

    # Allow nginx access to the copyparty unix socket.
    nginx.serviceConfig.SupplementaryGroups = [
      config.services.copyparty.group
    ];
  };

  home-manager.users.dermetfan = { options, ... }: {
    home.stateVersion = "26.05";

    profiles.dermetfan.environments = {
      admin.enable = true;
      desktop.enable = true;
      dev.enable = true;
      iog = {
        enable = true;
        reposDir = "/tank${options.profiles.dermetfan.environments.iog.reposDir.default}";
      };
    };

    # Uses unsupported CPU instruction (likely AVX) so crashes with SIGILL at runtime.
    # Enabled by the dev profile.
    programs.opencode-bwrap.enable = lib.mkForce false;
  };

  fileSystems."/mnt/copyparty/home" = {
    fsType = "fuse.bindfs";
    device = "/tank/home";
    options = [
      (with config.services.copyparty; "map=1000/${user}:@users/@${group}")
      "multithreaded"
      "nofail"
    ];
  };

  boot = {
    zfs = {
      extraPools = [ "tank" ];

      unlockEncryptedPoolsViaSSH = {
        enable = true;
        hostKeys = [
          /${<secrets>}/hosts/${name}/initrd_ssh_host_ed25519_key
        ];
      };
    };

    initrd = {
      network.ssh.port = 2222;

      services.zfs-rollback = {
        enable = true;
        snapshots = map lib.concatStrings [
          [ config.fileSystems."/".device     "@" "blank" ]
          [ config.fileSystems."/home".device "@" "blank" ]
        ];
      };
    };
  };
}
