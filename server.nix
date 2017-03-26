{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "dermetfan-server";

    firewall.allowedTCPPorts = [ 3000 25565 ];

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
      interface = "enp2s0";
    }];

    hydra = {
      enable = true;
      hydraURL = https://hydra.dermetfan.net/;
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

    ddclient = {
      enable = true;
      server = "dynupdate.no-ip.com";
      username = "dermetfan";
      password = builtins.readFile /etc/private/ddns-pass;
      domain = "dermetfan-server.ddns.net";
    };
  };

  systemd.services = {
    hydra-server.path = [ pkgs.ssmtp ];
    hydra-queue-runner.path = [ pkgs.ssmtp ];
  };

  system.stateVersion = "16.09";
}
