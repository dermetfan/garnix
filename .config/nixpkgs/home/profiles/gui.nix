{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.gui;
  sysCfg = config.passthru.systemConfig or {};
in {
  options.profiles.gui = with lib; {
    enable = mkEnableOption "xsession or wayland";
    enableEffects = mkOption {
      type = types.bool;
      description = "Whether to enable effects.";
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    xsession = {
      enable = sysCfg.services.xserver.enable or false;
      windowManager.i3.enable = config.xsession.enable or false;
      initExtra = ''
        xset r rate 225 27
        xset m 5 1
        syndaemon -d -i 0.625 -K -R || :
      '';
    };

    gtk.enable = config.profiles.gui.enable;
    qt = {
      enable = /*builtins.trace (builtins.toJSON config.systemd.user.targets.sway-session.Unit)*/ true;
      platformTheme = "gtk";
    };

    home = {
      sessionVariables.SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      
      packages = with pkgs;
        [
          x11_ssh_askpass
          libnotify
        ] ++
        lib.optionals config.xsession.enable [
          arandr
          xorg.xrandr
          xorg.xkill
          xclip
          xsel
        ] ++
        lib.optionals (!config.xsession.enable) [
          wdisplays
        ];
    };

    services = {
      unclutter.enable = config.xsession.enable && !sysCfg.services.unclutter.enable;
      picom.enable = config.xsession.enable && cfg.enableEffects;
    };

    wayland.windowManager.sway.enable = !config.xsession.enable;
    
    programs.swaylock.package = lib.mkIf cfg.enableEffects pkgs.swaylock-effects;
  };
}
