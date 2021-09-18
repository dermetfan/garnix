{ self, ... }:

{
  imports = [ self.inputs.agenix.nixosModules.age ];
}
