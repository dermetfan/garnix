{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking = {
    hostName = "dermetfan-server";

    firewall.allowedTCPPorts = [ 3000 ];

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

  i18n.consoleUseXkbConfig = true;

  time.timeZone = "Europe/Berlin";

  services = {
    openssh.enable = true;

    wakeonlan.interfaces = [{
      interface = "enp2s0";
    }];

    xserver = {
      layout = "us";
      xkbVariant = "norman";
      xkbOptions = "compose:lwin,compose:rwin,eurosign:e";
    };

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

    ddclient = {
      enable = true;
      server = "dynupdate.no-ip.com";
      username = "dermetfan";
      password = builtins.readFile /etc/private/ddns-pass;
      domain = "dermetfan-server.ddns.net";
    };
  };

  users = {
    mutableUsers = false;
    
    users = {
      root = {
        isSystemUser = true;
        hashedPassword = "$6$DldeafJwTCM2QA$1z4pdpJEm9wD7y4iFSBIoWtLIm36UEGnQeN0yqcVZ/jBT7pVshkWdsATQf6oBEyOECJMEw5yeuk.j04aSYI8N1";
      };

      dermetfan = {
        isNormalUser = true;
        hashedPassword = "$6$dermetfan$TDnNIlkKVSIUENPQxm6knvwguWBqfuLt4uTfzSl9gpZb1fQu86VIkvDzZ6dR02dt3c0QFwH4TOMoREMCDS7yt.";
        extraGroups = [
          "wheel"
        ];
      };
    };
  };

  system.stateVersion = "16.09";
}
