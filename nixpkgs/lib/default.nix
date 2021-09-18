self:

{
  generators = import ./generators.nix self;
  filesystem = import ./filesystem.nix self;
  flake = import ./flakes.nix self;
}
