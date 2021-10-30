{ config, lib, pkgs, ... }:

let
  yggdrasil = file:
    ../../secrets/hosts/nodes/${lib.removePrefix "node-" config.networking.hostName}/yggdrasil/${file};
in {
  imports = [
    node/bootstrap.nix
    ../imports/age.nix
  ];

  options.nix.buildMachine = with lib; mkOption {
    type = types.attrs;
    default = {
      inherit (config.nix) maxJobs;
      inherit (pkgs) system;
    };
  };

  config = {
    age.secrets."yggdrasil.conf".file = yggdrasil "keys.conf.age";

    networking = {
      domain = "dermetfan.net";
      useDHCP = false;
      hosts.${lib.fileContents (yggdrasil "ip")} = lib.mkDefault [ config.networking.hostName config.networking.fqdn ];
    };

    services = {
      "1.1.1.1".enable = true;
      openssh = {
        passwordAuthentication = false;
        challengeResponseAuthentication = false;
        hostKeys = [
          rec { type = "ed25519"; path = "/etc/ssh/ssh_host_${type}_key"; }
        ];
      };

      yggdrasil = {
        enable = true;
        configFile = config.age.secrets."yggdrasil.conf".path;
      };
    };

    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes ca-references recursive-nix
      '';
      binaryCachePublicKeys = [
        (builtins.readFile ../../secrets/services/cache.pub)
      ];

      systemFeatures = lib.mkDefault [ "recursive-nix" ];

      gc.automatic = true;
      optimise.automatic = true;
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [
      ../../secrets/deployer_ssh_ed25519_key.pub
    ];
  };
}
