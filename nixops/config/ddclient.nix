{ config, lib, ... }:

{
  services.ddclient = {
    server = "dynupdate.no-ip.com";
    username = "dermetfan";
    password = builtins.readFile ../../keys/ddns;
    domains = lib.mkDefault [ "${config.networking.hostName}.ddns.net" ];
    use = "web, web=icanhazip.com";
  };
}
