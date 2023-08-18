{ inputs, ... } @ parts:

{ config, pkgs, lib, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
  ];

  system.stateVersion = "22.05";

  profiles = {
    handson.enable = true;
    notebook.enable = true;
    gui.enable = true;
    users.enable = true;
    afraid-freedns.enable = true;
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

    xserver = {
      enable = true;

      layout = lib.mkForce "de";
      xkbVariant = lib.mkForce "";

      libinput.enable = true;

      displayManager = {
        autoLogin = {
          enable = true;
          user = config.users.users.lynn.name;
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

        "root/home/${config.users.users.lynn.name}" = {
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

  home-manager.users.lynn = { nixosConfig, config, ... }: {
    imports = [ parts.config.flake.homeManagerProfiles.dermetfan ];

    home = {
      stateVersion = "22.05";

      username = nixosConfig.users.users.lynn.name;
      homeDirectory = nixosConfig.users.users.lynn.home;

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "geany";
        PAGER = "less";
      };

      packages = with pkgs; [
        libreoffice
      ];
    };

    profiles.dermetfan.environments = {
      media.enable = true;
      office.enable = true;
    };

    services = {
      redshift = nixosConfig.passthru.coords or {};
      wlsunset = nixosConfig.passthru.coords or {};
    };

    programs = {
      alacritty.enable = true;
      geany.enable = true;
      less.enable = true;
      fish.enable = true;
      firefox.enable = true;
      chromium.enable = true;
      browserpass.enable = lib.mkForce false;
    };
  };

  users.users = {
    root.hashedPassword = lib.mkForce "$6$u9W4NZj2wPlDR.Vm$MC7J11xhII9DDfZ10Ev5Tna6jZX57KwKNiqiLOqR630kJsHNgpOaulFMsxQsFLfF9DUw.AsL/DnTcEYGwVO8q.";

    lynn = {
      isNormalUser = true;

      hashedPassword = "$6$am.ZfZ88QXPUe0zp$s6MPBjK73zC3Lt/Nsqb.CuKmrmKhGZosRIREHKfbdZMZ7Kn9WzkVVbLG1WCP6zJnopt4frMmW82pu.DNA4Cet1";

      extraGroups = [
        "wheel"
        "networkmanager"
        "video" # backlight
      ];
    };
  };

  fileSystems."/home/lynn" = {
    device = "root/home/lynn";
    fsType = "zfs";
  };

  networking.hostId = "8425e349";

  hardware.pulseaudio.package = pkgs.pulseaudioFull;
}
