_:

{ config, ... }:

let
  peersWithYggdrasil = builtins.filter
    (config: config.profiles.yggdrasil.enable)
    config.profiles.cluster.node.peers;
in

{
  services.yggdrasil.settings = {
    Peers = map (
      { networking, profiles, ... }:
      "tls://${networking.hostName}.hosts.${networking.domain}:${toString profiles.yggdrasil.port}"
    ) peersWithYggdrasil;

    AllowedPublicKeys = map (
      { services, ... }:
      services.yggdrasil.settings.PublicKey
    ) peersWithYggdrasil;
  };
}
