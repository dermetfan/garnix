{ config, ... }:

let
  peersWithYggdrasil = builtins.filter
    (config: config.profiles.yggdrasil.enable)
    config.profiles.cluster.node.peers;
in

{
  services.yggdrasil.mergeableConfig = {
    Peers = map (
      { networking, profiles, ... }:
      "tcp://${networking.hostName}.hosts.${networking.domain}:${toString profiles.yggdrasil.port}"
    ) peersWithYggdrasil;

    AllowedPublicKeys = map (
      { services, ... }:
      services.yggdrasil.config.PublicKey
    ) peersWithYggdrasil;
  };
}
