{ config, lib, ... }:

{
  options.profiles.dermetfan.services.mako.enable = lib.mkEnableOption "mako" // {
    default = config.services.mako.enable;
  };

  config = {
    services.mako.settings."mode=do-not-disturb".invisible = true;

    # The order of declarations does matter
    # (as noted here: https://github.com/emersion/mako/wiki/Volume-change-notification)
    # but the home-manager module does not support defining it.
    #
    # XXX Use `services.mako.extraConfig` instead when updating to 25.11:
    # https://github.com/nix-community/home-manager/issues/7120
    #
    # Ensure this comes last so it can override the do-not-disturb mode.
    xdg.configFile."mako/config".text = lib.mkAfter ''
      [app-name=mako]
      invisible=0
      history=0
    '';
  };
}
