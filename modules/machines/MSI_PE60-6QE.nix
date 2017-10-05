# Tested on: MSI PE60-6QEI781
{ config, lib, pkgs, ... }:

let
  cfg = config.config.machine."MSI PE60-6QE";
in {
  options.config.machine."MSI PE60-6QE" = {
    enable = lib.mkEnableOption "MSI PE60-6QE";

    hyperThreading = with lib; mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether Hyper-Threading is enabled.

        Sets <literal>nix.maxJobs</literal> and <literal>nix.buildCores</literal> to 8, otherwise 4.

        Remember the HyperThreading bug in Intel Skylake and Kaby Lake 6th and 7th gen, especially i7-6700K.
        This laptop is fitted with an i7-6700HQ and therefore affected without BIOS update.
      '';
    };

    enableBumblebeeHack = lib.mkEnableOption "the Bumblebee hack to turn off the dedicated GPU";
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

        tmpOnTmpfs = true;
      };

      nix = {
        maxJobs = if cfg.hyperThreading then 8 else 4;
        buildCores = if cfg.hyperThreading then 8 else 4;
      };

      hardware = {
        enableAllFirmware = true;
        opengl.driSupport32Bit = true;
        bluetooth.enable = true;
        pulseaudio = {
          package = pkgs.pulseaudioFull;
          support32Bit = true;
        };
      };

      services.xserver.videoDrivers = [ "intel" ];
    }
    (let
      script = pkgs.writeScript "bumblebeeHack.sh" ''
        #! ${pkgs.bash}/bin/bash
        case "$1" in
            start) systemctl start bumblebeed service ;;
            stop)  systemctl stop  bumblebeed service ;;
            poweron)  ${config.boot.kernelPackages.bbswitch}/bin/discrete_vga_poweron  ;;
            poweroff) ${config.boot.kernelPackages.bbswitch}/bin/discrete_vga_poweroff ;;
        esac
      '';
    in lib.mkIf cfg.enableBumblebeeHack {
      hardware.bumblebee.enable = true;

      systemd.services.bumblebeed.wantedBy = lib.mkForce [];

      services.xserver.displayManager.sessionCommands = ''
        sudo ${script} start
      '';

      security.sudo.extraConfig = ''
        %${config.users.groups.wheel.name} ALL=(ALL:ALL) NOPASSWD:${script}
      '';

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
  ]);
}
