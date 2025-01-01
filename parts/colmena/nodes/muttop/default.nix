{ getSystem, ... }:

{
  nodeNixpkgs = (getSystem "x86_64-linux").legacyPackages;

  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
