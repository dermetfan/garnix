_:

{ config, lib, ... }:

let
  cfg = config.profiles.notebook;
in {
  options.profiles.notebook.enable = lib.mkEnableOption "notebook settings";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
  };
}
