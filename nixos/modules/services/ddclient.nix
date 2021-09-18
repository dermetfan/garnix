{ config, lib, ... }:

{
  services.ddclient = {
    server = "dynupdate.no-ip.com";
    username = "dermetfan";
    password = null; # TODO ddclient has no way to load the password from another file so it ends up in ddclient.conf and the Nix store. Use something else.
    domains = lib.mkDefault [ "${config.networking.hostName}.ddns.net" ];
    use = "web, web=icanhazip.com";
  };
}
