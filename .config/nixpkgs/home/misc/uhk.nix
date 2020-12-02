{ config, lib, ... }:

{
  wayland.windowManager.sway.config.input."7504:24866:Ultimate_Gadget_Laboratories_Ultimate_Hacking_Keyboard" = {
    xkb_layout = config.home.keyboard.layout;
    xkb_variant = with lib; concatStringsSep "," (
      zipListsWith # remove variant for us layout (that is what UHK keymaps are for)
        (layout: variant: optionalString (layout != "us") variant)
        (splitString "," config.home.keyboard.layout)
        (splitString "," config.home.keyboard.variant)
    );
    xkb_options = "compose:rctrl";
  };
}
