{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  battery = "BAT0";
in

{
  imports = with inputs; [
    nixpkgs.nixosModules.notDetected
    disko.nixosModules.disko
    disko-zfs.nixosModules.default
    lanzaboote.nixosModules.default
  ];

  environment.persistence."/state".directories = [
    config.boot.lanzaboote.pkiBundle
    "/var/lib/auto-cryptenroll"
  ];

  home-manager.users.dermetfan = {
    profiles.dermetfan.programs.i3status-rust.batteries = [ battery ];

    home.keyboard.options = [ "starfighter" ];

    wayland.windowManager.sway = {
      keyboardIdentifier = "1:1:AT_Translated_Set_2_keyboard";
      clamshellOutput = "eDP-1";
    };
  };

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "rtsx_usb_sdmmc" ];
    kernelModules = [ "kvm-amd" ];

    loader = {
      systemd-boot.enable =
        if config.boot.lanzaboote.enable
        then lib.mkForce false
        else true;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true; # This must be false on initial install.
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        includeMicrosoftKeys = false;
        allowBrickingMyMachine = true;
        includeFirmwareBuiltinKeys = true;
      };
    };
  };

  services = {
    # Draws more power than charging can provide,
    # draining the battery even when plugged in.
    tlp.settings.CPU_BOOST_ON_AC = lib.mkForce 0;

    displayManager.ly.settings = {
      battery_id = battery;
      restart_key = "F5";
      hibernate_key = "F6";
      shutdown_key = "F7";
      brightness_down_key = "F8";
      brightness_up_key = "F9";
      show_password_key = "F12";
    };
  };

  hardware = {
    facter.reportPath = ./facter.json;

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    bluetooth.enable = true;
  };

  fileSystems."/state".neededForBoot = true;

  disko.devices = let
    luks = {
      enrollFido2 = true;
      extraFido2EnrollArgs = lib.cli.toCommandLineGNU {} {
        fido2-with-client-pin = builtins.toJSON true;
        fido2-with-user-presence = builtins.toJSON true;
      };

      # optimize for SSD
      settings = {
        allowDiscards = true;
        bypassWorkqueues = true;
      };
    };
  in {
    disk = {
      root = {
        device = "/dev/disk/by-id/nvme-eui.0025384351447b59";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            swap = {
              size = lib.pipe config.hardware.facter.reportPath [
                lib.importJSON
                (report: report.smbios.memory_device)
                (lib.fold ({ size, ... }: total: total + size) 0)
                (memoryKib: memoryKib / 1024 / 1024)
                (memoryGib: toString memoryGib + "G")
              ];
              content = luks // {
                type = "luks";
                name = "swap";
                content.type = "swap";
              };
            };

            root = {
              size = "100%";
              content = luks // {
                type = "luks";
                name = "root";
                content = {
                  type = "zfs";
                  pool = "root";
                };
              };
            };
          };
        };
      };

      tank = {
        device = "/dev/disk/by-id/nvme-eui.0025384651a40387";
        content = luks // {
          type = "luks";
          name = "tank";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
      };
    };

    zpool = let
      mkDatasets = lib.mapAttrs (_: v: v // {
        type = v.type or "zfs_fs";
        options =
          lib.optionalAttrs (v ? "mountpoint") {inherit (v) mountpoint;}
          // v.options or {};
      });
    in {
      root = {
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posix";
          xattr = "sa";
        };

        postCreateHook = ''
          zfs snapshot -r root@blank
          zfs hold -r blank root@blank
        '';

        datasets = mkDatasets {
          reserved.options = {
            refreserv = "${toString (builtins.floor (4 * 1024 * 0.2))}G"; # 20% of 4T because ZFS becomes slow at 80% usage
            canmount = "off";
          };

          root.mountpoint = "/";
          nix.mountpoint = "/nix";
          home.mountpoint = "/home";
          state.mountpoint = "/state";
        };
      };

      tank = {
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posix";
          xattr = "sa";
        };

        datasets = mkDatasets {
          reserved.options = {
            refreserv = "${toString (builtins.floor (4 * 1024 * 0.2))}G"; # 20% of 4T because ZFS becomes slow at 80% usage
            canmount = "off";
          };
        };
      };
    };
  };
}
