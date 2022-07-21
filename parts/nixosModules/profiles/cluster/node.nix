_:

{ lib, ... }:

{
  options.profiles.cluster.node.peers = with lib; mkOption {
    type = with types; listOf attrs;
    description = ''
      The NixOS configurations of this node's peers
      (that is, without this node itself).
    '';
    example = literalExpression ''
      map (peer: peer.config) (
        with self.outputs.nixosConfigurations;
        [ node-0 node-1 ]
      )
    '';
  };
}
