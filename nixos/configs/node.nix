{ self, config, lib, ... }:

{
  options.nix.buildMachine = with lib; mkOption {
    type = types.attrs;
    default = {
      inherit (config.nix) maxJobs;
      inherit (pkgs) system;
    };
  };

  config = {
    networking.domain = "dermetfan.net";

    profiles = {
      common.enable = true;
      yggdrasil.enable = true;
    };

    age.secrets = builtins.listToAttrs (map
      (id: let
        inherit (config.systemd.services."ceph-mon-${id}") serviceConfig;
      in lib.nameValuePair "ceph.mon.${id}.keyring" {
        file = ../../secrets/services/ceph.mon..keyring.age;
        path = "/var/lib/${serviceConfig.StateDirectory}/keyring";
        owner = serviceConfig.User;
      })
      config.services.ceph.mon.daemons
    );

    nix = {
      gc.automatic = true;
      optimise.automatic = true;
    };

    # XXX fix upstream?
    # Cannot use `services.ceph.mon.extraConfig` due to its type.
    environment.etc."ceph/ceph.conf".text = lib.generators.toINI {} (
      lib.genAttrs
        (map (daemon: "mon.${daemon}") config.services.ceph.mon.daemons)
        (daemon: { "public addr" = "[${config.profiles.yggdrasil.ip}]"; })
    );

    services = {
      openssh = {
        passwordAuthentication = false;
        challengeResponseAuthentication = false;
      };

      yggdrasil.mergeableConfig.Peers = lib.pipe ./nodes [
        builtins.readDir
        builtins.attrNames
        (map (name: self.nixosConfigurations.${name}.config))
        (builtins.filter (peerConfig: peerConfig.networking.hostName != config.networking.hostName))
        (builtins.filter (config: config.profiles.yggdrasil.enable))
        (map (
          { networking, profiles, ... }:
          "tcp://${networking.hostName}.hosts.${networking.domain}:${toString profiles.yggdrasil.port}"
        ))
      ];

      ceph = {
        global = let
          monInitialHosts = with self.nixosConfigurations; [ node-2 node-0 ];
        in {
          fsid = "efec54b4-7ee8-479d-ba1c-34c5eb766dfa";

          monInitialMembers = builtins.concatStringsSep "," (
            builtins.concatMap
              (h: h.config.services.ceph.mon.daemons)
              monInitialHosts
          );

          monHost = lib.concatMapStringsSep ","
            (host: "[${host.config.profiles.yggdrasil.ip}]")
            monInitialHosts;
        };

        extraConfig."ms bind ipv6" = builtins.toJSON true;

        mon.mkfs = true;
      };
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [
      ../../secrets/deployer_ssh_ed25519_key.pub
    ];
  };
}
