{ config, lib, pkgs, ... }:

let
  secrets = import config.bootstrap.secrets."secrets.nix".cleartext;
in {
  bootstrap.secrets."secrets.nix".path = null;

  system.stateVersion = "21.05";

  profiles = {
    default.enable = true;
    handson.enable = true;
    notebook.enable = true;
    gui.enable = true;
    dev.enable = true;
    users = {
      enable = true;
      users.dermetfan.enable = true;
    };
  };

  misc = {
    data = {
      enable = true;
      userFileSystems = true;
    };
    hotkeys.enableBacklightKeys = false; # handled by sway config
  };

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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
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
      iog.enable = true;
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
      syncthing.enable = true;
      redshift = secrets.coords;
      wlsunset = secrets.coords;
    };

    config.programs = {
      firefox.hideTabs = true;
      i3status-rust.data.enable = lib.mkForce false;
    };
  };
}
