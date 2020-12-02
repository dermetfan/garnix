{ config, lib, ... }:

{
  wayland.windowManager.sway.config.input."7504:24866:Ultimate_Gadget_Laboratories_Ultimate_Hacking_Keyboard" = {
    xkb_layout = config.home.keyboard.layout;
    xkb_variant = config.home.keyboard.variant;
    xkb_options = "compose:rctrl";
  };
}
