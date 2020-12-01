{ config, lib, ... }:

{
  wayland.windowManager.sway.config.input."7504:24866:Ultimate_Gadget_Laboratories_Ultimate_Hacking_Keyboard" = {
    xkb_layout = with lib; concatStringsSep "," (
      unique ( # reset layout in case it was changed
        [ "us" ] ++
        splitString "," config.home.keyboard.layout
      )
    );
    xkb_options = "compose:rctrl";
  };
}
