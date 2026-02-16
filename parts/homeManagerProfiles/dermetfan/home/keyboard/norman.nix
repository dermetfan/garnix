{ lib, ... }:

{
  home.keyboard = with lib; {
    layout = mkDefault "us";
    variant = mkDefault "norman";
    options = mkDefault [
      "ctrl:swapcaps"
      "compose:rctrl"
      "eurosign:e"
    ];
  };

  xsession.initExtra = ''
    # norman remaps these
    xmodmap -e "keycode 66 = Control_L"
    xmodmap -e "keycode 133 = Super_L"
    xmodmap -e "keycode 134 = Super_R"
    # norman had the compose key on Super_R
    xmodmap -e "keycode 105 = Multi_key" # Control_R
  '';
}
