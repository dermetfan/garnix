{ hardware ? {}
, config, pkgs, lib }:

lib.mkMerge [
  (import ./common.nix {
    inherit hardware config pkgs lib;
  })

  {
    nixpkgs.config.allowUnfree = true;

    networking = {
      hostName = "dermetfan-server";

      firewall.allowedTCPPorts = [
        80 443
        25575 # minecraft rcon
      ];

      defaultMailServer = {
        directDelivery = true;
        hostName = "smtp.gmail.com:587";
        root = "serverkorken@gmail.com";
        domain = "dermetfan.net";
        authUser = "serverkorken@gmail.com";
        authPass = builtins.readFile /etc/private/ssmtp-pass;
        useTLS = true;
        useSTARTTLS = true;
      };
    };

    services = {
      wakeonlan.interfaces = [{
        interface = hardware.interfaces.lan;
      }];

      hydra = {
        enable = true;
        hydraURL = https://hydra.dermetfan.net;
        notificationSender = "hydra@dermetfan.net";
        buildMachinesFiles = [];
        smtpHost = "localhost";
        logo = /var/lib/hydra/logo.png;
        tracker = ''
          <script>\
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\
          })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');\
          ga('create', 'UA-41218161-3', 'auto');\
          ga('send', 'pageview');\
          </script>\
        '';
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
        virtualHosts = {
          "server.dermetfan.net" = {
            default = true;
            forceSSL = true;
            enableACME = true;
            sslCertificate = /etc/private/host.cert;
            sslCertificateKey = /etc/private/host.key;
            locations = {
              "/minecraft/resourcepacks/".extraConfig = ''
                alias ${config.services.minecraft-server.dataDir}/resourcepacks/;
              '';
            };
          };

          "hydra.dermetfan.net" = {
            forceSSL = true;
            enableACME = true;
            sslCertificate = /etc/private/host.cert;
            sslCertificateKey = /etc/private/host.key;
            locations."/" = {
              proxyPass = "http://localhost:${builtins.toString config.services.hydra.port}";
            };
          };
        };
      };

      ddclient = {
        enable = true;
        server = "dynupdate.no-ip.com";
        username = "dermetfan";
        password = builtins.readFile /etc/private/ddns-pass;
        domain = "dermetfan-server.ddns.net";
        use = "web, web=icanhazip.com";
      };
    };

    systemd.services = {
      hydra-server.path = [ pkgs.ssmtp ];
      hydra-queue-runner.path = [ pkgs.ssmtp ];
    };
  }
]
