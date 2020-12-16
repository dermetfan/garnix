{ config, lib, ... }:

{
  services.nginx = {
    recommendedOptimisation  = true;
    recommendedProxySettings = true;
    recommendedTlsSettings   = true;
    recommendedGzipSettings  = true;
  };

  networking.firewall.allowedTCPPorts = lib.optionals config.services.nginx.enable [ 80 443 ];

  deployment.keys."host.key" = lib.mkIf config.services.nginx.enable {
    keyFile = ../../keys/host.key;
    user  = config.users.users.nginx.name; # FIXME use "acme" user
    group = config.users.users.nginx.group;
  };

  # XXX may be removed in the future
  # see https://github.com/NixOS/nixpkgs/issues/101445
  # see https://github.com/NixOS/nixpkgs/pull/100356
  # see https://github.com/NixOS/nixpkgs/pull/101726
  users.users.nginx = lib.mkIf config.services.nginx.enable {
    extraGroups = [ "acme" ];
  };
}
