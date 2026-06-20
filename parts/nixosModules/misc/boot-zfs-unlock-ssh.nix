_:

{ config, lib, pkgs, ... }:

let
  cfg = config.boot.zfs.unlockEncryptedPoolsViaSSH;

  hostKeys = lib.forEach cfg.hostKeys (pathOrStr: pkgs.writeText "ssh_host_key" (
    if builtins.isPath pathOrStr
    then builtins.readFile pathOrStr
    else pathOrStr
  ));
in {
  options.boot.zfs.unlockEncryptedPoolsViaSSH = with lib; {
    enable = lib.mkEnableOption "unlocking ZFS encrypted pools over SSH in the initial ramdisk";
    hostKeys = mkOption {
      type = with types; listOf (either path str);
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.singleton {
      assertion = lib.any (key:
        lib.fileContents key != ""
      ) config.boot.initrd.network.ssh.hostKeys;
      message = "At least one SSH host key for the initial ramdisk is empty!";
    };

    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        inherit hostKeys;

        extraConfig = ''
          Match All
            ForceCommand systemctl default
        '';
      };
    };

    # https://github.com/NixOS/nixpkgs/issues/98100
    system.extraDependencies = hostKeys;
  };
}
