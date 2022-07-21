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

## Bootstrap Secrets

Run the bootstrap script to copy the SSH host keys to the target machine.

```
nix run .#nixosConfigurations.node-3.config.passthru.bootstrap
```

This is necessary because agenix uses them to decrypt its secrets.

This setup largely follows the instructions on the [NixOS wiki](https://nixos.wiki/wiki/NixOS_on_ZFS#Unlock_encrypted_zfs_via_ssh_on_boot) for unlocking the root ZFS pool during the initial ramdisk.

Due to a NixOS [bug](https://github.com/NixOS/nixpkgs/issues/98100) the SSH host keys for the initial ramdisk have to be copied to the target machine prior to `nixos-rebuild`. I could have had the bootstrap script do this but then another NixOS [bug](https://github.com/NixOS/nixpkgs/issues/114594) would strike. As a workaround they are added to `system.extraDependencies` so they are in the system closure. This of course means we lose all advantages of `boot.initrd.secrets`, which works by appending to the initrd during `nixos-rebuild` and is therefore incompatible with remote deployments, and the keys end up world-readable in the Nix store. Unfortunately this is the only way that I am currently aware of to make deployments work reliably.

## Ceph Setup

Create MON and MGR by following steps from one of the Ceph NixOS tests.
I did this on nixpkgs rev `65be52ba2ae75cd930227be00861a24dd344bec6`.

You could create OSDs the same way but we want to encrypt them which is not done in the NixOS tests.
Follow these steps instead which I adapted from the [Ceph manual](https://docs.ceph.com/en/latest/install/manual-deployment/#bluestore):

```
# prepare temporary environment
sudo -u ceph mkdir /var/lib/ceph/bootstrap-osd
ceph auth get client.bootstrap-osd -o /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo -u ceph ln -s /var/lib/ceph/bootstrap-osd/ceph.keyring /etc/ceph/ceph.client.bootstrap-osd.keyring
nix profile install nixpkgs#cryptsetup

ceph-volume lvm create --bluestore --data /dev/disk/by-id/… --dmcrypt --no-systemd

# remove temporary environment
rm /var/lib/ceph/bootstrap-osd /etc/ceph/ceph.client.bootstrap-osd.keyring
nix profile remove …
```

The NixOS tests do not set up an MDS but it is simple.
For example, for an MDS called `a` on the default cluster named `ceph`:

```
ceph auth get-or-create mds.a osd "allow rwx" mds "allow *" mon "allow profile mds" > /var/lib/ceph/mds/ceph-a/keyring
```

# I Learned

## Encrypted ZFS Root

GRUB does [not support](https://github.com/zfsonlinux/grub/issues/24) encrypted ZFS. Even if only one arbitrary dataset in the root pool is encrypted, `grub-probe` will fail.

Since I don't know a BIOS bootloader that supports encrypted ZFS, that means we cannot use BIOS boot but have to use UEFI so that we can put the initrd on a separate boot partition that is not in an encrypted zpool. I use systemd-boot and a simple 512 MiB vfat partition for this.

## Hetzner's Boot

Hetzner Online's Server has legacy+UEFI boot enabled so one would think that UEFI would just work. However, by default it first does network boot into "Hetzner PXE boot manager", that then checks if Hetzner's rescue system is activated, and if not boots from local drive **in legacy mode**. Therefore UEFI does actually not work. You have to join their UEFI beta to be able to boot the rescue system with UEFI.

If you don't want to join the UEFI beta you can switch from legacy+UEFI to UEFI only boot mode as a workaround. This skips "Hetzner PXE boot manager" (which does legacy boot) and goes directly to UEFI boot (according to your boot order settings). Therefore this is incompatible with Hetzner's rescue systems. You need a "KVM console" (which has nothing to do with KVM) to get access to the BIOS using a NoVNC connection (web VNC client).
