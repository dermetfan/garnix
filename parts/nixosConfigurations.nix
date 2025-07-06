{ config, ... }:

{
  flake.nixosConfigurations = config.flake.colmenaHive.nodes;
}
