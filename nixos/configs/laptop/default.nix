{
  system = "x86_64-linux"; # XXX use localSystem instead? see `man configuration.nix` for `nixpkgs.pkgs`
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
