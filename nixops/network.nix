{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;
in {
  network.description = "dermetfan.net";

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

      services = {
        disnix.enable = true;

        ddclient = {
          enable = true;
          server = "dynupdate.no-ip.com";
          username = "dermetfan";
          password = builtins.readFile ../keys/ddns;
          domain = lib.mkDefault "${config.networking.hostName}.ddns.net";
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

      users.users = {
        root.openssh.authorizedKeys.keyFiles =
          lib.optional (config.node.name != nodes.master.config.node.name) ../keys/master_rsa.pub;

        nix-serve.extraGroups = [ "keys" ];
        nginx    .extraGroups = [ "keys" ];
      };
    };
  };

  master = { config, pkgs, lib, nodes, ... }: {
    config = {
      deployment.keys = {
        master_rsa.keyFile = ../keys/master_rsa;

        "cache.sec" = {
          keyFile = ../keys/cache.sec;
          user = config.users.users.nix-serve.name;
          permissions = "0440";
        };

        "host.key" = {
          keyFile = ../keys/host.key;
          user = config.users.users.nginx.name;
          group = config.users.users.nginx.group;
          permissions = "0440";
        };

        ssmtp = {
          keyFile = ../keys/ssmtp;
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
        }) (builtins.attrValues nodes);
      };

      nixpkgs.config.allowUnfree = true;

      networking = {
        firewall.allowedTCPPorts = [
          80 443
          25575 # minecraft RCON
        ];

        defaultMailServer = {
          directDelivery = true;
          hostName = "smtp.gmail.com:587";
          root = "serverkorken@gmail.com";
          domain = "dermetfan.net";
          authUser = "serverkorken@gmail.com";
          authPass = "/run/keys/ssmtp";
          useTLS = true;
          useSTARTTLS = true;
        };
      };

      services = {
        nix-serve = {
          enable = true;
          secretKeyFile = "/run/keys/cache.sec";
        };

        hydra = {
          enable = true;
          hydraURL = https://hydra.dermetfan.net;
          notificationSender = "hydra@dermetfan.net";
          buildMachinesFiles = [];
          smtpHost = "127.0.0.1";
          logo = lib.mkDefault /var/lib/hydra/logo.png;
        };

        minecraft-server = {
          enable = true;
          openFirewall = true;
        };

        nginx = {
          enable = true;
          recommendedOptimisation = true;
          recommendedProxySettings = true;
          recommendedTlsSettings = true;
          recommendedGzipSettings = true;
          virtualHosts = let
            forceSSL = x: x // {
              forceSSL = true;
              enableACME = true;
              sslCertificate = ../keys/host.crt;
              sslCertificateKey = "/run/keys/host.key";
            };
          in {
            "server.dermetfan.net" = forceSSL {
              default = true;
              locations = {
                "/minecraft/resourcepacks/".alias = "${config.services.minecraft-server.dataDir}/resourcepacks/";
              };
            };

            "hydra.dermetfan.net" = forceSSL {
              locations."/".proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}";
            };

            "cache.dermetfan.net" = forceSSL {
              locations."/".proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}";
            };
          };
        };
      };

      systemd.services = {
        hydra-server.path       = [ pkgs.ssmtp ];
        hydra-queue-runner.path = [ pkgs.ssmtp ];
      };
    };
  };
}
