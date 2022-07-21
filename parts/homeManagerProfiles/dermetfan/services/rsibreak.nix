{ config, lib,  ... }:

let
  cfg = config.profiles.dermetfan.services.rsibreak;
in {
  options.profiles.dermetfan.services.rsibreak.enable = lib.mkEnableOption "rsibreak" // {
    default = config.services.rsibreak.enable;
  };

  config.xdg.configFile."rsibreakrc".text = ''
    [General]
    AutoStart=false

    [General Settings]
    BigDuration=2
    BigInterval=60
    BigThreshold=5
    DisableAccel=true
    Effect=2
    ExpandImageToFullScreen=true
    Graylevel=80
    HideLockButton=true
    HideMinimizeButton=false
    HidePostponeButton=false
    ImageFolder=${config.xdg.userDirs.pictures}/wallpapers
    Patience=30
    PostponeBreakDuration=1
    SearchRecursiveCheck=true
    ShowSmallImagesCheck=true
    SlideInterval=5
    TinyDuration=20
    TinyInterval=15
    TinyThreshold=40
    UseNoIdleTimer=true
    UsePlasmaReadOnly=true

    [Popup Settings]
    UseFlash=true
    UsePopup=true
  '';
}
