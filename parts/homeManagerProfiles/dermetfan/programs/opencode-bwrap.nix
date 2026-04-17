{ self, config, lib, pkgs, ... }:

{
  imports = [
    self.inputs.opencode-bwrap.homeManagerModules.default
  ];

  programs.opencode-bwrap = {
    dataDirPrefix = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome + "/opencode-bwrap";
    extraPackages = with pkgs; [ python3 ];
  };
}
