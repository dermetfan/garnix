{ lib, ... }:

{
  home.keyboard = with lib; {
    layout = mkDefault "us";
    variant = mkDefault "norman";
    options = mkDefault [
      # "compose:lwin"
      "compose:rctrl"
      "eurosign:e"
      "caps:capslock"
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
}
