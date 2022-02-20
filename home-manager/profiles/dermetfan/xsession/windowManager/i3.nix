{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.xsession.windowManager.i3;
in {
  options.profiles.dermetfan.xsession.windowManager.i3.enable = lib.mkEnableOption "i3" // {
    default = config.xsession.enable && config.xsession.windowManager.i3.enable;
  };

  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3.config.keybindings = let
      mod = config.xsession.windowManager.i3.config.modifier;
    in {
      "${mod}+k" = ''exec "i3-msg reload && timeout 1.75 i3-nagbar -t warning -m 'reloaded i3 configuration'"'';
      "${mod}+Shift+k" = ''exec "i3-msg restart && timeout 1.75 i3-nagbar -t warning -m 'restarted i3 inplace'"'';
      "${mod}+Ctrl+k" = ''exec "i3-nagbar -t warning -m 'Exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"'';
    };
  };
}
