{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
  ];

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
        daemons = [ "a" ];
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
      game.enable = true;
    };

    home = {
      stateVersion = "22.05";

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
    };

    programs = {
      broot.settings.special_paths."/mnt/cephfs/home/dermetfan" = "no-enter";

      firefox.hideTabs = true;

      beets.settings = let
        dir = "/mnt/cephfs/home/dermetfan/media/audio/music/library";
      in {
        directory = lib.mkForce dir;
        library = lib.mkForce "${dir}/beets.db";
      };
    };
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
