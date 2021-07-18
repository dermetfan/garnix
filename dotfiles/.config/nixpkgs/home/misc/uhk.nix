{ config, lib, ... }:

{
  wayland.windowManager.sway.config.input."7504:24866:Ultimate_Gadget_Laboratories_UHK_60_v1" = {
    xkb_layout = config.home.keyboard.layout;
    xkb_variant = with lib; concatStringsSep "," (
      zipListsWith # remove variant for us layout (that is what UHK keymaps are for)
        (layout: variant: optionalString (layout != "us") variant)
        (splitString "," config.home.keyboard.layout)
        (splitString "," config.home.keyboard.variant)
    );
    xkb_options = "compose:rctrl";

    inherit (config.wayland.windowManager.sway.config.input."type:keyboard") repeat_delay repeat_rate;

    accel_profile = "flat";
    pointer_accel = "0";
  };
}
