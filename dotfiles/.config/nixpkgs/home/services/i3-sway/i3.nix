{ config, lib, ... }:

let
  cfg = config.config.xsession.windowManager.i3;
  common = import ./common.nix {
    inherit config lib;
    inherit (cfg) enableGaps;
    cfg = config.xsession.windowManager.i3;
  };
in {
  options.config.xsession.windowManager.i3 = {
    enable = with lib; mkOption {
      type = types.bool;
      default = config.xsession.enable && config.xsession.windowManager.i3.enable;
      description = "Whether to configure i3.";
    };

    enableGaps = with lib; mkOption {
      type = types.bool;
      default = true;
      description = "Whether to configure i3-gaps.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    common.config
    { xsession.windowManager.i3 = common.i3-sway; }
    {
      xsession.windowManager.i3.config.keybindings = let
        mod = config.xsession.windowManager.i3.config.modifier;
      in {
        "${mod}+k" = ''exec "i3-msg reload && timeout 1.75 i3-nagbar -t warning -m 'reloaded i3 configuration'"'';
        "${mod}+Shift+k" = ''exec "i3-msg restart && timeout 1.75 i3-nagbar -t warning -m 'restarted i3 inplace'"'';
        "${mod}+Ctrl+k" = ''exec "i3-nagbar -t warning -m 'Exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"'';
      };
    }
  ]);
}
