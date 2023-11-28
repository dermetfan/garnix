{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
  ];

  system.stateVersion = "23.05";

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
    yggdrasil.enable = true;
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

    home.stateVersion = "23.05";

    xsession.initExtra = ''
      telegram-desktop &
    '';

    services = {
      redshift = config.passthru.coords or {};
      wlsunset = config.passthru.coords or {};
    };

    programs.firefox.hideTabs = true;
  };
}
