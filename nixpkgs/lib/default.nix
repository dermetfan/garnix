self:

{
  generators = import ./generators.nix self;
  filesystem = import ./filesystem.nix self;
  modules = import ./modules.nix self;
  flake = import ./flakes.nix self;
}
