# Tested on: MSI PE60-6QEi781
{ config, lib, pkgs, ... }:

let
  cfg = config.hardware."MSI PE60-6QE";
in {
  options.hardware."MSI PE60-6QE" = with lib; {
    enable = mkEnableOption "MSI PE60-6QE";

    hyperThreading = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether Hyper-Threading is enabled.

        Sets <option>nix.maxJobs</option> to 8, otherwise 4.

        Remember the HyperThreading bug in Intel Skylake and Kaby Lake 6th and 7th gen, especially i7-6700K.
        This laptop is fitted with an i7-6700HQ and therefore affected without BIOS update.
      '';
    };

    enableGPU = mkOption {
      type = types.enum [ true false "bumblebee" ];
      default = "bumblebee";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nixpkgs.config.allowUnfree = true;

      boot = {
        initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "usb_storage"
          "usbhid"
          "sd_mod"
          "sr_mod"
          "rtsx_usb_sdmmc"
        ];

        kernelModules = [ "kvm-intel" ];

        blacklistedKernelModules = [
          "nouveau" # causes CPU stalls with intel GPU driver (HyperThreading bug?)
        ];

        tmpOnTmpfs = lib.mkDefault true;
      };

      nix.maxJobs = if cfg.hyperThreading then 8 else 4;

      hardware = {
        enableAllFirmware = true;
        bluetooth.enable = true;
        pulseaudio.package = pkgs.pulseaudioFull;
      };
    }

    (let
      script = pkgs.writeScript "bumblebeeHack.sh" ''
        #! ${pkgs.bash}/bin/bash
        case "$1" in
            start) systemctl start bumblebeed.service ;;
            stop)  systemctl stop  bumblebeed.service ;;
            poweron)  ${config.boot.kernelPackages.bbswitch}/bin/discrete_vga_poweron  ;;
            poweroff) ${config.boot.kernelPackages.bbswitch}/bin/discrete_vga_poweroff ;;
        esac
      '';
    in lib.mkIf (cfg.enableGPU == "bumblebee") {
      services.xserver.videoDrivers = [ "intel" ];

      hardware.bumblebee.enable = true;

      systemd.services.bumblebeed.wantedBy = lib.mkForce [];

      services.xserver.displayManager = let
        hasSlim = lib.versionOlder lib.version "20.03";
      in {
        # There is no generic post display manager hook
        # so this will only start, but not stop, bumblebeed.
        sessionCommands = lib.optionalString (
          (!hasSlim || !config.services.xserver.displayManager.slim.enable) &&
          !config.services.xserver.displayManager.sddm.enable
        ) "${script} start";

        sddm = {
          setupScript = "${script} start";
          stopScript  = "${script} stop";
        };
      } // (lib.optionalAttrs hasSlim {
        slim.extraConfig = ''
          sessionstart_cmd ${script} start
          sessionstop_cmd  ${script} stop
        '';
      });

      powerManagement = let
        pid = "/run/bumblebeed.pid";
      in {
        powerDownCommands = ''
          test -e ${pid} && ${script} poweron
        '';

        resumeCommands = ''
          test -e ${pid} && ${script} poweroff
        '';
      };
    })

    (lib.mkIf (cfg.enableGPU == true) {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;

        prime = {
          sync.enable = true;
          nvidiaBusId = "PCI:1:0:0";
          intelBusId  = "PCI:0:2:0";
        };
      };
    })

    (lib.mkIf (cfg.enableGPU == false) {
      services.xserver.videoDrivers = [ "intel" ];

      hardware.nvidiaOptimus.disable = true;
    })

    { specialisation = with lib; {
      performance.configuration.config = {
        boot.loader.grub.configurationName = "MSI PE60-6QE: performance";

        powerManagement.cpuFreqGovernor = mkForce "performance";

        hardware."MSI PE60-6QE".enableGPU = mkForce true;
      };

      powersave.configuration.config = {
        boot.loader.grub.configurationName = "MSI PE60-6QE: powersave";

        powerManagement.cpuFreqGovernor = mkForce "powersave";

        hardware."MSI PE60-6QE".enableGPU = mkForce false;
      };

      bumblebee.configuration.config = {
        boot.loader.grub.configurationName = "MSI PE60-6QE: bumblebee";

        hardware."MSI PE60-6QE".enableGPU = mkForce "bumblebee";
      };
    }; }
  ]);
}
