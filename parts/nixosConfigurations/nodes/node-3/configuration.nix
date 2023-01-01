{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
    inputs.filestash.nixosModules.default
  ];

  system.stateVersion = "21.11";

  environment = {
    persistence."/state" = {
      files = map (key: key.path) config.services.openssh.hostKeys;
      directories = [
        "/var/lib/acme"
        "/var/lib/ceph"
        config.services.postgresql.dataDir
      ];
    };

    systemPackages = with pkgs; [ bindfs ];
  };

  age = {
    # https://github.com/ryantm/agenix/issues/45
    identityPaths = map (key: "/state${toString key.path}") config.services.openssh.hostKeys;

    secrets = {
      "ceph.client.fs.keyring" = {
        file = ../../../../secrets/services/ceph.client.fs.keyring.age;
        path = "/etc/ceph/ceph.client.fs.keyring";
        owner = config.users.users.ceph.name;
        group = config.users.users.ceph.group;
      };

      "ceph.client.roundcube.keyring" = {
        file = ../../../../secrets/services/ceph.client.roundcube.keyring.age;
        path = "/etc/ceph/ceph.client.roundcube.keyring";
        owner = config.users.users.ceph.name;
        group = config.users.users.ceph.group;
      };

      filestash = {
        file = ../../../../secrets/services/filestash.age;
        owner = config.services.filestash.user;
        group = config.services.filestash.group;
      };
    };
  };

  profiles.roundcube.enable = true;

  services = {
    homepage.enable = true;

    webdav = {
      enable = true;

      settings = {
        address = "127.0.0.1";
        port = 4918;
        auth = true;

        modify = true;

        cors = {
          enabled = true;
          credentials = true;
          allowed_methods = [ "GET" ];
          exposed_headers = [
            "Content-Length"
            "Content-Range"
          ];
        };

        users = lib.mapAttrsToList
          (username: password: {
            inherit username password;
            scope = "/mnt/webdav/home/${username}";
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
          url = "https://webdav.${config.networking.domain}";
          inherit username;
        }) [
          "dermetfan"
          "diemetfan"
          "mutmetfan"
        ];
      };
    };

    nginx.virtualHosts = let
      extraConfig = ''
        client_max_body_size 5G;
        proxy_request_buffering off;
      '';
    in {
      "webdav.${config.networking.domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/".proxyPass = with config.services.webdav.settings; "http://${address}:${toString port}";

        inherit extraConfig;
      };

      ${config.services.filestash.settings.general.host} = {
        enableACME = true;
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:${toString config.services.filestash.settings.general.port}";

        inherit extraConfig;
      };
    };

    znapzend = {
      pure = true;
      zetup = let
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
        planFew = "1week=>1day,1month=>1week";
        planMany = "1week=>1day,1hour=>15minutes,15minutes=>5minutes,1day=>1hour,1year=>1month,1month=>1week";
      in {
        "root/root" = {
          inherit timestampFormat recursive;
          plan = planFew;
        };
        "root/nix" = {
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
      };
    };

    yggdrasil.publicPeers.germany.enable = true;

    ceph = {
      enable = true;
      mon = {
        enable = true;
        daemons = [ "c" ];
        openFirewall = true;
      };
      mgr = {
        enable = true;
        daemons = [ "c" ];
        dashboard.enable = true;
        openFirewall = true;
      };
      mds = {
        enable = true;
        daemons = [ "c" ];
        openFirewall = true;
      };
      osd = {
        enable = true;
        daemons = [ "4" "5" ];
        activate = {
          "4" = "623369b5-6240-45ac-bb7f-c5874cc0d89f";
          "5" = "2b59ed1f-a637-4324-8e0c-6315cb99a7ef";
        };
        openFirewall = true;
      };
      client.enable = true;
    };
  };

  fileSystems = {
    ${config.services.roundcube.settings.enigma_pgp_homedir} = {
      fsType = "fuse.ceph-fixed";
      device = "none";
      options = [
        "nofail"
        "ceph.id=roundcube"
        "ceph.client_mountpoint=/services/roundcube/enigma"
      ];
    };

    "/mnt/webdav/home" = {
      fsType = "fuse.bindfs";
      device = "/mnt/cephfs/home";
      options = [
        "map=1000/webdav:@users/@webdav"
        "nofail"
      ];
    };

    "/mnt/cephfs/home" = {
      device = "none";
      fsType = "fuse.ceph-fixed";
      options = [
        "nofail"
        "ceph.id=fs"
        "ceph.client_mountpoint=/home"
      ];
    };
  };

  bootstrap.secrets.initrd_ssh_host_ed25519_key.path = null;

  boot = {
    zfs.unlockEncryptedPoolsViaSSH = {
      enable = true;
      hostKeys = [
        config.bootstrap.secrets.initrd_ssh_host_ed25519_key.cleartext
      ];
    };

    initrd = {
      network.ssh.port = 2222;

      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r root/root@blank
        zfs rollback -r root/home@blank
      '';
    };
  };
}
