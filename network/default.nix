{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;
in {
  network.description = "dermetfan.net";

  defaults = { config, nodes, ... }: {
    imports = [ ../system ];

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

      services.disnix.enable = true;

      programs.ssh.knownHosts = map (node: {
        hostNames = [ node.config.deployment.targetHost ];
        publicKey = builtins.readFile (../keys + "/${node.config.node.name}_rsa.pub");
      }) (builtins.attrValues nodes);

      users.users.root.openssh.authorizedKeys.keyFiles = [ ../keys/master_rsa.pub ];
    };
  };

  master = { lib, config, pkgs, nodes, ... }: {
    config = {
      config.data.enable = true;

      nix = {
        gc.automatic = true;
        optimise.automatic = true;
      };

      system.autoUpgrade.enable = true;

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
          authPass = builtins.readFile ../keys/ssmtp;
          useTLS = true;
          useSTARTTLS = true;
        };
      };

      services = {
        nix-serve = {
          enable = true;
          secretKeyFile = "../keys/cache.sec";
        };

        hydra = {
          enable = true;
          hydraURL = https://hydra.dermetfan.net;
          notificationSender = "hydra@dermetfan.net";
          buildMachinesFiles = [];
          smtpHost = "localhost";
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
              sslCertificateKey = ../keys/host.key;
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

        ddclient = {
          enable = true;
          server = "dynupdate.no-ip.com";
          username = "dermetfan";
          password = builtins.readFile ../keys/ddns;
          domain = "dermetfan-server.ddns.net";
          use = "web, web=icanhazip.com";
        };
      };

      systemd.services = {
        hydra-server.path       = [ pkgs.ssmtp ];
        hydra-queue-runner.path = [ pkgs.ssmtp ];
      };
    };
  };
}
