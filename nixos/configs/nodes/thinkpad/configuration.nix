{ config, pkgs, lib, ... }:

{
  imports = [ ../../../imports/age.nix ];

  system.stateVersion = "20.03";

  age.secrets."ceph.client.diemetfan.keyring" = {
    file = ../../../../secrets/services/ceph.client.diemetfan.keyring.age;
    path = "/etc/ceph/ceph.client.diemetfan.keyring";
  };

  profiles = {
    handson.enable = true;
    notebook.enable = true;
    gui.enable = true;
    users.enable = true;
  };

  i18n.defaultLocale = "de_DE.UTF-8";

  console.font = "Lat2-Terminus16";

  time.timeZone = "Europe/Berlin";

  services = {
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = config.users.users.marlene.home + "/Sync";
      # cannot take from config.users.{users|groups}.{marlene|wheel}.name
      # due to infinite recursion
      user = "marlene";
      group = "users";
    };

    ceph = {
      enable = true;
      client.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    xserver = {
      enable = true;

      layout = lib.mkForce "de";
      xkbVariant = lib.mkForce "";

      libinput.enable = true;

      displayManager = {
        autoLogin = {
          enable = true;
          user = config.users.users.marlene.name;
        };
        sddm.enable = true;
      };

      desktopManager.lxqt.enable = true;
    };

    blueman.enable = true;

    logind.lidSwitch = lib.mkForce "suspend";

    znapzend = {
      enable = true;
      zetup = let
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
      in {
        root = {
          plan = "1week=>1day,1month=>1week";
          inherit timestampFormat;
        };

        "root/home/${config.users.users.marlene.name}" = {
          plan = "15min=>5min,1hour=>15min,1day=>1hour,1week=>1day,1month=>1week";
          inherit timestampFormat;
        };
      };
    };
  };

  sound.enable = true;

  programs.nm-applet.enable = true;

  environment = {
    systemPackages = with pkgs; [
      brightnessctl
    ];

    # TODO Does it really work to run a command here?
    sessionVariables.GDK_PIXBUF_MODULE_FILE = "$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)";
  };

  home-manager.users.marlene = lib.mkMerge [
    (import ../../../../home-manager)
    ({ nixosConfig, config, ... }: {
      users.diemetfan = true;

      home = {
        stateVersion = "21.05";

        username = nixosConfig.users.users.marlene.name;
        homeDirectory = nixosConfig.users.users.marlene.home;
      };

      profiles = {
        media.enable = true;
        office.enable = true;
      };

      services = {
        redshift = nixosConfig.passthru.coords or {};
        wlsunset = nixosConfig.passthru.coords or {};
      };

      programs = {
        firefox.enable = true;
        browserpass.enable = lib.mkForce false;
      };
    })
  ];

  users.users.marlene = {
    isNormalUser = true;

    hashedPassword = "$6$jj92FejhdockmW$5NjOp0/HFBjO.YhxbPEDKx3FSebO0QP1bU.iQIArCVpe7Ca6ZzXGGxux1GnDBRxca8LPtFb.pyo7gvbA8Kz5X1";

    extraGroups = [
      "wheel"
      "networkmanager"
      "video" # backlight
      "ceph"
    ];
  };

  fileSystems = {
    "/home/marlene" = {
      device = "root/home/marlene";
      fsType = "zfs";
    };

    "/home/marlene/cephfs" = {
      device = "none";
      fsType = "fuse.ceph-fixed";
      options = [
        "nofail"
        "ceph.id=diemetfan"
        "ceph.client_mountpoint=/home/diemetfan"
      ];
    };
  };

  networking.hostId = "8425e349";

  hardware.pulseaudio.package = pkgs.pulseaudioFull;
}
