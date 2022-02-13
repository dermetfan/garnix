{ self, config, lib, pkgs, ... }:

let
  cfg = config.profiles.common;
in {
  imports = [ self.inputs.hosts.nixosModule ];

  options.profiles.common.enable = lib.mkEnableOption "common settings";

  config = lib.mkIf cfg.enable {
    defaults.enable = true;

    profiles.users.enable = true;

    nix = {
      binaryCachePublicKeys = [
        (builtins.readFile ../../../secrets/services/cache.pub)
      ];

      package = pkgs.nixUnstable;

      systemFeatures = lib.mkDefault [ "recursive-nix" ];

      extraOptions = ''
        experimental-features = nix-command flakes recursive-nix
      '';
    };

    time.timeZone = "Europe/Berlin";

    networking.stevenBlackHosts.enable = true;

    security.acme.email = "serverkorken@gmail.com";

    programs = {
      mosh.enable = true;
      tmux.enable = true;
    };

    services = {
      openssh = {
        enable = true;
        hostKeys = [
          rec { type = "ed25519"; path = "/etc/ssh/ssh_host_${type}_key"; }
        ];
      };

      "1.1.1.1".enable = true;

      znapzend.enable = builtins.any (x: x == "zfs") (map
        (fs: fs.fsType)
        (builtins.attrValues config.fileSystems)
      );
    };
  };
}
