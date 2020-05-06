{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;
  domain = "dermetfan.net";
in {
  network.description = domain;

  defaults = { config, lib, nodes, ... }: {
    imports = [ ../nixos ];

    options.node = {
      name = with lib; mkOption {
        type = types.str;
        default = config._module.args.name;
      };

      buildMachine = with lib; mkOption {
        type = types.attrs;
        default = {
          inherit (config.nix) maxJobs;
        };
      };
    };

    config = {
      networking.hostName = lib.mkOverride 899 "dmf-${config.node.name}";

      security.acme = {
        acceptTerms = true;
        email = "serverkorken@gmail.com";
      };

      services = {
        ddclient = {
          enable = true;
          server = "dynupdate.no-ip.com";
          username = "dermetfan";
          password = builtins.readFile ../keys/ddns;
          domains = lib.mkDefault [ "${config.networking.hostName}.ddns.net" ];
          use = "web, web=icanhazip.com";
        };
      };

      programs.ssh.knownHosts = map (node: {
        hostNames = [ node.config.deployment.targetHost ];
        publicKey = lib.strings.removeSuffix
          " root@${node.config.networking.hostName}\n"
          (builtins.readFile (../keys + "/${node.config.node.name}_rsa.pub"));
      }) (lib.filter (node:
        node.config.node.name != config.node.name
      ) (builtins.attrValues nodes));

      users.users.root.openssh.authorizedKeys.keyFiles =
        lib.optional (config.node.name != nodes.master.config.node.name) ../keys/master_rsa.pub;
    };
  };

  master = { config, pkgs, lib, nodes, ... }: {
    imports = [
      # nix-binary-cache-cache
      "${(builtins.fetchGit {
        url = https://gist.github.com/f495fc6cc4130f155e8b670609a1e57b.git;
        rev = "ea9052f1bd4d5c57b0abe3d0c1ff3786b3c02d79";
      }).outPath}/nix-binary-cache-cache.nix"
    ];

    config = {
      deployment.keys = lib.mapAttrs (name: value: {
        permissions = "0440";
      } // value) {
        master_rsa.keyFile = ../keys/master_rsa;

        "cache.sec" = lib.mkIf config.services.nix-serve.enable {
          keyFile = ../keys/cache.sec;
          user = config.users.users.nix-serve.name;
        };

        "host.key" = {
          keyFile = ../keys/host.key;
          user  = config.users.users.nginx.name;
          group = config.users.users.nginx.group;
        };

        ssmtp.keyFile = ../keys/ssmtp;

        nextcloud = {
          keyFile = ../keys/nextcloud;
          user  = config.users.users.nextcloud.name;
          group = config.users.users.nextcloud.group;
        };
      };

      config.data.enable = true;

      nix = {
        gc.automatic = true;
        optimise.automatic = true;

        distributedBuilds = true;
        buildMachines = map (node: node.config.node.buildMachine // {
          hostName = node.config.deployment.targetHost;
          sshUser = "root";
          sshKey = "/run/keys/master_rsa";
        }) (builtins.attrValues (
          lib.filterAttrs (name: node: node.extraArgs.name != config.node.name) nodes
        ));
      };

      nixpkgs.config.allowUnfree = true;

      networking = {
        firewall.allowedTCPPorts =
          [ 80 443 ] ++
          lib.optional (config.services.syncthing.enable        && config.services.syncthing.openDefaultPorts)    8384 ++ # web GUI
          lib.optional (config.services.minecraft-server.enable && config.services.minecraft-server.openFirewall) 25575; # RCON

        defaultMailServer = {
          directDelivery = true;
          hostName = "smtp.gmail.com:587";
          root = "serverkorken@gmail.com";
          inherit domain;
          authUser = "serverkorken@gmail.com";
          authPassFile = "/run/keys/ssmtp";
          useTLS = true;
          useSTARTTLS = true;
        };
      };

      services = {
        nix-serve = {
          enable = !(config.services.nixBinaryCacheCache.enable or false);
          secretKeyFile = "/run/keys/cache.sec";
        };

        nixBinaryCacheCache = {
          enable = true;
          virtualHost = "cache.${domain}";
          resolver = lib.concatStringsSep " " config.networking.nameservers +
            lib.optionalString (!config.networking.enableIPv6) " ipv6=off";
        };

        syncthing = {
          enable = true;
          openDefaultPorts = true;
        };

        hydra = {
          enable = true;
          hydraURL = "https://hydra.${domain}";
          notificationSender = "hydra@${domain}";
          buildMachinesFiles = [];
          useSubstitutes = true;
          smtpHost = "127.0.0.1";
        };

        minecraft-server = {
          enable = true;
          eula = true;
          openFirewall = true;
        };

        nextcloud = {
          enable = true;
          hostName = "nextcloud.${domain}";
          nginx.enable = true;
          config = {
            adminuser = "dermetfan";
            adminpassFile = "/run/keys/nextcloud";
          };
        };

        shellinabox = {
          enable = true;
          extraOptions = [
            "--localhost-only"
            "--user-css Dark:+${pkgs.shellinabox}/lib/white-on-black.css,Light:-/dev/null"
          ];
        };

        nginx = {
          enable = true;
          recommendedOptimisation  = true;
          recommendedProxySettings = true;
          recommendedTlsSettings   = true;
          recommendedGzipSettings  = true;
          virtualHosts = let
            withSSL = x: x // {
              enableACME = true;
              sslCertificate = ../keys/host.crt;
              sslCertificateKey = "/run/keys/host.key";
            };
          in {
            "server.${domain}" = withSSL {
              default = true;
              forceSSL = true;
              locations = {
                "/minecraft/resourcepacks/".alias = "${config.services.minecraft-server.dataDir}/resourcepacks/";
                "/shellinabox".proxyPass = http://127.0.0.1:4200/;
                "/gotty/" = {
                  proxyPass = http://127.0.0.1:4201/;
                  proxyWebsockets = true;
                };
              };
            };

            "hydra.${domain}" = withSSL {
              forceSSL = true;
              locations."/".proxyPass = let
                # nginx does not understand * for all interfaces
                listenHost = if config.services.hydra.listenHost == "*"
                  then "0.0.0.0"
                  else config.services.hydra.listenHost;
              in "http://${listenHost}:${toString config.services.hydra.port}";
            };

            ${config.services.nixBinaryCacheCache.virtualHost or "cache.${domain}"} = withSSL {
              forceSSL = true;
            } // (if config.services.nix-serve.enable then {
              locations."/".proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}";
            } else {});

            ${config.services.nextcloud.hostName} = withSSL {
              forceSSL = true;
            };
          };
        };
      };

      systemd.services = {
        hydra-server.path       = [ pkgs.ssmtp ];
        hydra-queue-runner.path = [ pkgs.ssmtp ];

        gotty = {
          wantedBy = [ "multi-user.target" ];
          path = [ pkgs.gotty ];
          script = "gotty /run/current-system/sw/bin/login";
          environment = {
            GOTTY_PORT = "4201";
            GOTTY_PERMIT_WRITE = "1";
          };
        };
      };
    };
  };
}
