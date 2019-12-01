{ config, lib, pkgs, ... }:

let
  cfg = config.config.services.rsibreak;
in {
  options.config.services.rsibreak.enable = with lib; mkOption {
    type = types.bool;
    default = config.services.rsibreak.enable;
    defaultText = "<option>services.rsibreak.enable</option>";
  };

  config.xdg.configFile = lib.mkIf cfg.enable {
    "rsibreakrc".text = ''
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
  };
}
