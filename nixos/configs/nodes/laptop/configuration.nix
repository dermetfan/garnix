{ config, lib, pkgs, ... }:

{
  imports = [ ../../../imports/age.nix ];

  system.stateVersion = "21.05";

  age.secrets."ceph.client.dermetfan.keyring" = {
    file = ../../../../secrets/services/ceph.client.dermetfan.keyring.age;
    path = "/etc/ceph/ceph.client.dermetfan.keyring";
  };

  profiles = {
    handson.enable = true;
    notebook.enable = true;
    gui.enable = true;
    dev.enable = true;
    iog.enable = true;
    users = {
      enable = true;
      users.dermetfan.enable = true;
    };
    afraid-freedns.enable = true;
  };

  misc.hotkeys.enableBacklightKeys = false; # handled by sway config

  hardware.yubikey.enable = true;

  # for i3status-rust eco block
  security.sudo.extraRules = lib.mkAfter [
    {
      commands = [ {
        command = "${pkgs.linuxPackages.cpupower}/bin/cpupower";
        options = [ "NOPASSWD" ];
      } ];
      groups = [ config.users.groups.wheel.gid ];
    }
  ];

  services = {
    yggdrasil.publicPeers.germany.enable = true;

    ceph = {
      enable = true;
      mon = {
        enable = true;
        daemons = [ "c" ];
        openFirewall = true;
      };
      client.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  home-manager.users.dermetfan.config = {
    profiles = {
      admin.enable = true;
      dev = {
        enable = true;
        enableRust = true;
        enableWeb = true;
      };
      media.enableEditors = true;
      office.enable = true;
      gui.enable = true;
      desktop.enable = true;
      game.enable = true;
    };

    home = {
      stateVersion = "20.09";

      packages = with pkgs; [
        asciinema
      ];
    };

    xsession.initExtra = ''
      telegram-desktop &
    '';

    services = {
      redshift = config.passthru.coords or {};
      wlsunset = config.passthru.coords or {};

      unison = {
        enable = true;
        pairs.cephfs = {
          roots = [
            config.users.users.dermetfan.home
            "/mnt/cephfs/home/dermetfan"
          ];
          commandOptions = {
            include = "cephfs";
            mountpoint = ".local";
            repeat = toString (60 * 15);
            owner = builtins.toJSON true;
            group = builtins.toJSON true;
            times = builtins.toJSON true;
            sortnewfirst = builtins.toJSON true;
            sortbysize = builtins.toJSON true;
            watch = builtins.toJSON false;
          };
        };
      };
    };

    programs.broot.config.special_paths."/mnt/cephfs/home/dermetfan" = "no-enter";

    config.programs.firefox.hideTabs = true;
  };

  fileSystems."/mnt/cephfs/home/dermetfan" = {
    device = "none";
    fsType = "fuse.ceph-fixed";
    options = [
      "nofail"
      "ceph.id=dermetfan"
      "ceph.client_mountpoint=/home/dermetfan"
    ];
  };
}
