# How to Install

## Boot Into The NixOS Installer

Based upon the instructions on the [NixOS wiki](https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Online).

1. Build a kexec image.
	`nix run github:nix-community/nixos-generators -- -f kexec-bundle -c installer.nix -o kexec_nixos`
2. Boot the server into Hetzner's rescue system.
3. Copy the image onto the server.
	`scp kexec_nixos root@…:`
4. On the server, switch to root and run the image.
	```
	cd /
	/root/kexec_nixos
	```

## Disk Setup

ZFS layout after partitioning:

```
zpool create -O acltype=posix -O xattr=sa -O mountpoint=none -O encryption=on -O keyformat=passphrase root …

zfs create -o mountpoint=legacy root/root
zfs create -o mountpoint=legacy root/nix
zfs create -o mountpoint=legacy root/home
zfs create -o mountpoint=legacy root/state

zfs snap -r root@blank

mount -t zfs root/root /mnt
mkdir /mnt/nix; mount -t zfs root/nix /mnt/nix
mkdir /mnt/home; mount -t zfs root/home /mnt/home
mkdir /mnt/state; mount -t zfs root/state /mnt/state

# space reservation to protect against completely filling up the pool
zfs create -o refreserv=1G -o mountpoint=none -o canmount=off root/reserved
```

Adapted from Graham Christensen's blog post ["Erase your darlings"](https://grahamc.com/blog/erase-your-darlings).

## Imperative Steps

Run the bootstrap script to copy the SSH host keys to the target machine.

```
nix run .#nixosConfigurations.node-2.config.passthru.bootstrap
```

This is necessary because agenix uses them to decrypt its secrets.

This setup largely follows the instructions on the [NixOS wiki](https://nixos.wiki/wiki/NixOS_on_ZFS#Unlock_encrypted_zfs_via_ssh_on_boot) for unlocking the root ZFS pool during the initial ramdisk.

Due to a NixOS [bug](https://github.com/NixOS/nixpkgs/issues/98100) the SSH host keys for the initial ramdisk have to be copied to the target machine prior to `nixos-rebuild`. I could have had the bootstrap script do this but then another NixOS [bug](https://github.com/NixOS/nixpkgs/issues/114594) would strike. As a workaround they are added to `system.extraDependencies` so they are in the system closure. This of course means we lose all advantages of `boot.initrd.secrets`, which works by appending to the initrd during `nixos-rebuild` and is therefore incompatible with remote deployments, and the keys end up world-readable in the Nix store. Unfortunately this is the only way that I am currently aware of to make deployments work reliably.
