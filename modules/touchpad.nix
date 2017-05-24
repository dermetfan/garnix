{ config }:

let
  settings = config.passthru.settings.touchpad or {};
in {
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    palmDetect = true;
  } // settings;
}
