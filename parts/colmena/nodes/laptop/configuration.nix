{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
  ];

  system.stateVersion = "25.05";

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

  programs.light.brightnessKeys.enable = lib.mkForce false; # handled by sway config

  hardware.yubikey.enable = true;

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

    home.stateVersion = "25.05";

    services.wlsunset = config.passthru.coords or {};

    programs.firefox.hideTabs = true;
  };

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
}
