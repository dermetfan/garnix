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

  system.stateVersion = "25.05";

  environment = {
    persistence."/state" = {
      files = map (key: key.path) config.services.openssh.hostKeys;
      directories = [
        "/var/lib/nixos"
        "/var/lib/acme"
        config.services.postgresql.dataDir
        "/var/lib/authelia-${config.services.authelia.instances.default.name}"
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
    };
  };

  profiles = {
    roundcube.enable = true;
    yggdrasil.enable = true;
    ntfy-sh.enable = true;
    users.users.dermetfan.enable = true;
    dev.enable = true;
    iog.enable = true;
  };

  programs.ssh.extraConfig = ''
    Host znapzend-node-0
      Hostname ${with nodes.node-0.config.networking; "${hostName}.hosts.${domain}"}
  '' + lib.concatMapStringsSep "\n" (key: "  IdentityFile ${key.path}") config.services.openssh.hostKeys + "\n" + ''
      User znapzend
      IdentitiesOnly yes
  '';

  services = {
    # For some reason, NixOS 25.05 does not default to PostgreSQL 17; NixOS 25.11 will, though.
    # https://github.com/NixOS/nixpkgs/pull/417502/files#diff-332df55682746a7949fbc279642f4b761456b3470ce93c541924a69ce8a45763
    postgresql.package =
      assert config.services.postgresql.enable;
      pkgs.postgresql_17;

    homepage.enable = true;

    copyparty = {
      enable = true;

      settings = options.services.copyparty.settings.default // rec {
        i = [ "unix:770:/dev/shm/party.sock" ];
        s-tbody = 0;
        http-only = true;

        rproxy = 1;

        # usernames = true; # XXX add once available
        no-bauth = true;

        ah-alg = "argon2";

        idp-h-usr = config.services.authelia.nginx.virtualHosts.default.authenticatedHeaders.user;
        idp-h-grp = config.services.authelia.nginx.virtualHosts.default.authenticatedHeaders.groups;
        idp-gsep = ",";
        idp-h-key = "Shangala-Bangala";
        idp-store = 3;
        idp-adm = [ "@admin" ];

        # TODO fix upstream: This is not comma-separated, it's repeatable,
        # but the NixOS module will turn it into a single comma-separated value,
        # making it impossible to set multiple of these using the NixOS module.
        ipu = [ "${nodes.muttop.config.profiles.yggdrasil.ip}/128=mutmetfan" ];

        # Usually the group is given by the IdP,
        # but apparently it is not recovered from the IdP cache
        # when logging in via `--ipu`, so let's set it explicitely.
        # TODO fix upstream: This is not comma-separated, it's repeatable,
        # but the NixOS module will turn it into a single comma-separated value,
        # making it impossible to set multiple of these using the NixOS module.
        grp = [ "default:mutmetfan" ];

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

        chmod-f = 640;
        chmod-d = 750;

        # reflink = true; # README says "zfs had bugs"
        df = "256m";

        nid = true;
      };

      # XXX NixOS module does not support IdP syntax; fix upstream?
      #"/home/\${u}" = {
      #  path = "${config.fileSystems."/mnt/copyparty/home".mountPoint}/\${u}";
      #  access.A = [ "@admin" "\${u}" ];
      #};
      volumes =
        lib.mapAttrs' (user: lib.nameValuePair "/home/${user}") (lib.genAttrs [
          "dermetfan"
          "diemetfan"
          "mutmetfan"
        ] (user: {
          path = "${config.fileSystems."/mnt/copyparty/home".mountPoint}/${user}";
          access.A = [ "@admin" user ];
          flags.daw = builtins.elem user [ "mutmetfan" ];
        }))
        # Needed to avoid WebDAV errors with GVFS.
        // lib.genAttrs ["/" "/home"] (volume: rec {
          path = "/var/empty";
          access.r = "@default";
          flags = {
            d2d = true;
            # Must be unique per volume.
            hist = "${path}${volume}.hist";
          };
        });

      # TODO report issue
      # Needed to make --ipu work with IdP.
      # Crashes on startup without this.
      # The password was generated from `head --bytes (math 2^32) /dev/random | sha512sum`.
      # Nobody should ever know it as authentication should be done only via the IdP.
      accounts.mutmetfan.passwordFile = builtins.toFile "unknown-pwhash" "+-JCTwpHZ6a2sQMSWh4s9Z3jilLcGCCBY";
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
            client_max_body_size 0;
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

  systemd.services = {
    # TODO Will probably be needed once the copyparty NixOS module
    # supports IdP syntax in the volumes config, see comment above.
    #copyparty.serviceConfig.BindPaths = [
    #  config.fileSystems."/mnt/copyparty/home".mountPoint
    #];

    # Allow nginx access to the copyparty unix socket.
    nginx.serviceConfig.SupplementaryGroups = [
      config.services.copyparty.group
    ];
  };

  home-manager.users.dermetfan = { options, ... }: {
    home.stateVersion = "25.05";

    profiles.dermetfan.environments = {
      admin.enable = true;
      dev.enable = true;
      iog = {
        enable = true;
        reposDir = "/tank${options.profiles.dermetfan.environments.iog.reposDir.default}";
      };
    };
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
          (builtins.extraBuiltins.readSecret ../../../../secrets/hosts/${name}/initrd_ssh_host_ed25519_key.age)
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
