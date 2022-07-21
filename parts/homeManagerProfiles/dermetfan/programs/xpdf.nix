{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.xpdf;
in {
  options.profiles.dermetfan.programs.xpdf.enable = lib.mkEnableOption "Xpdf" // {
    default = config.programs.xpdf.enable or false;
  };

  config.home.file.".xpdfrc".text = ''
    continuousView yes
    initialZoom width
  '';
}
