{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  stateDir = config.environment.persistence."/state".persistentStoragePath;
in

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "25.11";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unrar"
    "Oracle_VirtualBox_Extension_Pack"
  ];

  deployment.keys.ssh_host_key.destDir = lib.mkForce "${stateDir}/etc/ssh";

  # https://nixos.org/manual/nixos/stable/#ch-system-state
  environment.persistence."/state" = {
    files = map (key: key.path) config.services.openssh.hostKeys ++ [
      "/etc/machine-id"
      "/etc/zfs/zpool.cache"
    ];
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log/journal"
    ];
  };

  # https://github.com/ryantm/agenix/issues/45
  age.identityPaths = map (key: stateDir + toString key.path) config.services.openssh.hostKeys;

  profiles = {
    handson.enable = true;
    notebook.enable = true;
    gui.enable = true;
    dev.enable = true;
    users = {
      enable = true;
      users.dermetfan.enable = true;
    };
    yggdrasil.enable = true;
  };

  programs.light.brightnessKeys.enable = lib.mkForce false; # handled by sway config

  # for i3status-rust eco block
  security.sudo.extraRules = lib.mkAfter [
    {
      commands = [ {
        command = lib.getExe config.services.tlp.package;
        options = [ "NOPASSWD" ];
      } ];
      groups = [ config.users.groups.wheel.gid ];
    }
  ];

  services = {
    yggdrasil.publicPeers.germany.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    znapzend = {
      enable = true;
      zetup = let
        planFew = "1week=>1day,1month=>1week";
        planMany = "1week=>1day,1hour=>15minutes,15minutes=>5minutes,1day=>1hour,1year=>1month,1month=>1week";
      in lib.mapAttrs (k: v: {
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
      } // v) {
        "root/root".plan = planFew;
        "root/home".plan = planMany;
        "root/state".plan = planMany;
      };
    };
  };

  home-manager.users.dermetfan = {
    profiles.dermetfan.environments = {
      admin.enable = true;
      dev = {
        enable = true;
        enableRust = true;
        enableWeb = true;
      };
      iog.enable = true;
      media.enableEditors = true;
      office.enable = true;
      gui.enable = true;
      desktop.enable = true;
    };

    home.stateVersion = "25.11";

    services = {
      wlsunset = config.passthru.coords or {};

      way-displays = {
        enable = true;
        settings = {
          LOG_THRESHOLD = "WARNING"; # To avoid notifications on lid switch.
          ALIGN = "BOTTOM";
          SCALE = [
            {
              NAME_DESC = "eDP-1";
              SCALE = 1.2;
            }
          ];
          MODE = [
            {
              NAME_DESC = "eDP-1";
              WIDTH = 2560;
              HEIGHT = 1600;
              HZ = 60.002;
            }
          ];
        };
      };
    };
  };

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  boot.initrd.systemd.services.zfs-rollback = {
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-${config.disko.devices.zpool.root.name}.service" ];
    before = [ "sysroot.mount" ];

    path = [ config.boot.zfs.package ];
    script = "zfs rollback -r ${config.fileSystems."/".device}@blank";

    serviceConfig.Type = "oneshot";
    unitConfig.DefaultDependencies = "no";
  };
}
