{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.services.mako;
in {
  options.profiles.dermetfan.services.mako = {
    enable = lib.mkEnableOption "mako" // {
      default = config.services.mako.enable;
    };

    desktop = {
      category = lib.mkOption {
        type = lib.types.str;
        default = "desktop";
        description = ''
          Category name for desktop notifications.
          Shown even in do-not-disturb mode.
          Shows only the last notification.
          Does not get saved into history.
        '';
      };

      progressApp = lib.mkOption {
        type = lib.types.str;
        default = "progress";
        description = ''
          App name for percentage visualization.
          Only applies to the desktop category.
        '';
      };
    };
  };

  config = {
    services.mako.settings = {
      max-history = 20;
      "mode=do-not-disturb".invisible = true;
    };

    # The order of declarations does matter
    # as noted [here](https://github.com/emersion/mako/wiki/Volume-change-notification)
    # but the home-manager module does not support defining it.
    #
    # XXX Use `services.mako.extraConfig` instead when updating to 25.11:
    # https://github.com/nix-community/home-manager/issues/7120
    #
    # Ensure this comes last so it can override the do-not-disturb mode.
    xdg.configFile."mako/config".text = lib.mkAfter ''
      [category=${cfg.desktop.category}]
      invisible=false
      history=false
      layer=overlay
      group-by=category
      # like the default format but without the group-index
      format=<b>%s</b>\n%b

      [category=${cfg.desktop.category} grouped]
      invisible=true

      [category=${cfg.desktop.category} grouped group-index=0]
      invisible=false

      [category=${cfg.desktop.category} app-name=${cfg.desktop.progressApp}]
      # like `[category=${cfg.desktop.category}]` but with space instead of newline
      format=<b>%s</b> %b
    '';
  };
}
