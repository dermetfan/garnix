{ inputs, ... } @ parts:

{ nodes, config, pkgs, lib, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "25.05";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "brscan4"
    "brscan4-etc-files"
    "brother-udev-rule-type1"
  ];

  environment.persistence."/state" = {
    files = map (key: key.path) config.services.openssh.hostKeys;
    directories = [
      "/var/lib/nixos"
    ];
  };

  # https://github.com/ryantm/agenix/issues/45
  age.identityPaths = map (key: "/state${toString key.path}") config.services.openssh.hostKeys;

  profiles = {
    handson.enable = true;
    notebook.enable = true;
    gui.enable = true;
    users.enable = true;
    yggdrasil.enable = true;
  };

  i18n.defaultLocale = "de_DE.UTF-8";

  console.font = "Lat2-Terminus16";

  time.timeZone = "Europe/Berlin";

  services = {
    yggdrasil.publicPeers.germany.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    displayManager = {
      enable = true;
      sddm = {
        enable = true;
        autoNumlock = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = config.users.users.muttop.name;
      };
    };

    libinput.enable = true;

    xserver = {
      enable = true;

      xkb = {
        layout = lib.mkForce "de";
        variant = lib.mkForce "";
      };

      desktopManager.lxqt.enable = true;
    };

    blueman.enable = true;

    logind.lidSwitch = lib.mkForce "suspend";

    znapzend = {
      enable = true;
      zetup = let
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
        planFew = "1week=>1day,1month=>1week";
        planMany = "1week=>1day,1hour=>15minutes,15minutes=>5minutes,1day=>1hour,1year=>1month,1month=>1week";
      in {
        "root/root" = {
          inherit timestampFormat recursive;
          plan = planFew;
        };

        "root/home" = {
          inherit timestampFormat recursive;
          plan = planMany;
        };
      };
    };

    printing = {
      enable = true;
      stateless = true;
    };
  };

  programs.nm-applet.enable = true;

  # Avoids evaluation error due to undefined option value in pure evaluation
  # below in home-manager's redshift and wlsunset services.
  passthru = {};

  home-manager.users.mutmetfan = { nixosConfig, config, ... }: {
    imports = [
      parts.config.flake.homeManagerProfiles.defaults
      ./xdg-config.nix
    ];

    home = {
      stateVersion = "25.05";

      username = nixosConfig.users.users.mutmetfan.name;
      homeDirectory = nixosConfig.users.users.mutmetfan.home;

      sessionVariables.EDITOR = "geany";

      packages = with pkgs; [
        libreoffice
        liberation_ttf_v2
        qpdfview
        simple-scan
      ];
    };

    services.redshift = lib.optionalAttrs (nixosConfig ? passthru.coords) {
      enable = true;
      tray = true;
      inherit (nixosConfig.passthru.coords) latitude longitude;
    };

    programs = {
      geany.enable = true;
      less.enable = true;
      fish.enable = true;
      firefox.enable = true;
      chromium.enable = true;
    };

    xdg.portal = {
      extraPortals = with pkgs; [
        lxqt.xdg-desktop-portal-lxqt
      ];
      config.lxqt.default = [ "lxqt" ];
    };

    gtk = {
      enable = true;
      gtk3.bookmarks = [
        (let
          node-3 = nodes.node-3.config;
          webdavUsers = builtins.listToAttrs (map (user: lib.nameValuePair user.username user) node-3.services.webdav.settings.users);
          webdavYggPort = (builtins.elemAt node-3.services.nginx.virtualHosts."webdav.ygg.${node-3.networking.domain}".listen 0).port;
        in "dav://${webdavUsers.mutmetfan.username}@[${node-3.profiles.yggdrasil.ip}]:${toString webdavYggPort}/ Server")
      ];
    };
  };

  users.users = {
    root.hashedPassword = lib.mkForce "$6$u9W4NZj2wPlDR.Vm$MC7J11xhII9DDfZ10Ev5Tna6jZX57KwKNiqiLOqR630kJsHNgpOaulFMsxQsFLfF9DUw.AsL/DnTcEYGwVO8q.";

    mutmetfan = {
      isNormalUser = true;

      hashedPassword = "$6$8Vd1aOeNzVstrZ5d$dqkCqDfj6J0wr7R0BphQBr8KdO.mJHpqpLDTsq4FNNxGNRreYCzofiQnmN1noPyvIxuvQRBcQwPP1oUMygwqv/";

      extraGroups = [
        "wheel"
        "networkmanager"
        "video" # backlight
        "lp" # printing
        "scanner"
      ];
    };
  };

  networking.hostId = "8425e349";

  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r root/root@blank
  '';
}
