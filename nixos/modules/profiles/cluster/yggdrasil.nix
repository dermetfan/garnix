{ config, lib, ... }:

{
  services.yggdrasil.mergeableConfig.Peers = lib.pipe config.profiles.cluster.node.peers [
    (builtins.filter (config: config.profiles.yggdrasil.enable))
    (map (
      { networking, profiles, ... }:
      "tcp://${networking.hostName}.hosts.${networking.domain}:${toString profiles.yggdrasil.port}"
    ))
  ];
}
