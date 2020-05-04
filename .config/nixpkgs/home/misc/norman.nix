{ config, lib, ... }:

let
  cfg = config.config.norman;
in {
  options.config.norman = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the norman keyboard layout.";
    };

    swayKeyboardIdentifier = mkOption {
      type = types.str;
      default = "type:keyboard";
      description = ''
        Input device identifier for sway to apply norman to.
        Use this if the default (all keyboards)
        messes with your config for other keyboards
        where you do not want the norman layout.
      '';
    };
  };

  config = {
    home.keyboard = {
      layout = "us";
      variant = "norman";
      options = [
        # "compose:lwin"
        "compose:rwin"
        "eurosign:e"
        # "caps:capslock" # handled in xsession.initExtra
      ];
    };

    xsession.initExtra = ''
      # norman remaps these but we want to keep them
      xmodmap -e "keycode 66 = Caps_Lock"
      xmodmap -e "keycode 133 = Super_L"
      xmodmap -e "keycode 134 = Super_R"
      # norman had the compose key on Super_R
      xmodmap -e "keycode 105 = Multi_key" # Control_R
    '';

    wayland.windowManager.sway.config.input.${cfg.swayKeyboardIdentifier} = {
      xkb_layout = config.home.keyboard.layout;
      xkb_variant = config.home.keyboard.variant;
      xkb_options = "compose:rctrl,caps:capslock";
    };
  };
}
