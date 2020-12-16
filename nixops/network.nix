{
  network.description = "dermetfan.net";

  defaults = { config, lib, nodes, ... }: {
    imports = [
      ./config
      ../nixos
    ];

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
        ddclient.enable = true;

        openssh = {
          passwordAuthentication = false;
          challengeResponseAuthentication = false;
        };
      };

      programs.ssh.knownHosts = lib.listToAttrs (map (node: {
        name = node.config.deployment.targetHost;
        value.publicKey = lib.strings.removeSuffix
          " root@${node.config.networking.hostName}\n"
          (builtins.readFile (../keys + "/${node.config.node.name}_rsa.pub"));
      }) (lib.filter (node:
        node.config.node.name != config.node.name
      ) (builtins.attrValues nodes)));

      users.users.root.openssh.authorizedKeys.keyFiles =
        lib.optional (config.node.name != nodes.master.config.node.name) ../keys/master_rsa.pub;

      nix = {
        gc.automatic = true;
        optimise.automatic = true;
      };
    };
  };

  master = { config, pkgs, lib, nodes, ... }: {
    config = {
      deployment.keys.master_rsa.keyFile = ../keys/master_rsa;

      nix = {
        distributedBuilds = true;
        buildMachines = map (node: node.config.node.buildMachine // {
          hostName = node.config.deployment.targetHost;
          sshUser = "root";
          sshKey = "/run/keys/master_rsa";
        }) (builtins.attrValues (
          lib.filterAttrs (name: node: node.extraArgs.name != config.node.name) nodes
        ));
      };

      config.data.enable = true; # XXX should this belong to hardware config?

      services = {
        syncthing.enable = true;
        # hydra.enable = true;
        minecraft-server.enable = true;
        nextcloud.enable = true;
        ssmtp.enable = true;


        nginx.virtualHosts."asb.siegstrolche.de".locations."/".proxyPass = "http://127.0.0.1:8080";
      };
    };
  };

  node1 = { config, lib, ... }: {
    users.users.roman = {
      isNormalUser = true;
      password = "keins";
      extraGroups = [ "wheel" ];
    };

    services.openssh = {
      passwordAuthentication = lib.mkForce true;
      challengeResponseAuthentication = lib.mkForce true;
    };

    networking.firewall = {
      allowedTCPPorts = lib.optionals config.services.samba.enable [ 139 445 ];
      allowedUDPPorts = lib.optionals config.services.samba.enable [ 137 138 ];
    };

    services.samba = {
      enable = true;
      shares.roman = {
        path = config.users.users.roman.home;
        browseable = "yes";
        "guest ok" = "yes";
        comment = "Roman's Dateien";
      };
    };
  };
}
