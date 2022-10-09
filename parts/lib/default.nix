lib:

{
  attrsets = import ./attrsets.nix lib;
  filesystem = import ./filesystem.nix lib;
  generators = import ./generators.nix lib;
  modules = import ./modules.nix lib;
  flakes = import ./flakes.nix lib;
  tests = lib.runTests (import ./tests.nix lib);
}
