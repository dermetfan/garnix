{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.xpdf;
in {
  options       .programs.xpdf.enable = lib.mkEnableOption "Xpdf";
  options.config.programs.xpdf.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.xpdf.enable;
    defaultText = "<option>programs.xpdf.enable</option>";
    description = "Whether to configure Xpdf.";
  };

  config.home.packages = lib.optional config.programs.xpdf.enable pkgs.xpdf;
  config.home.file = lib.mkIf cfg.enable {
    ".xpdfrc".text = ''
      continuousView yes
      initialZoom width
    '';
  };
}
