{ config, lib, ... }:

{
  options.profiles.dermetfan.services.mako.enable = lib.mkEnableOption "mako" // {
    default = config.services.mako.enable;
  };

  config.services.mako.settings."mode=do-not-disturb".invisible = true;
}
