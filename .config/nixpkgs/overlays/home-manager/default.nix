self: super:

{
  home-manager = import ./home-manager {
    pkgs = self;
    modulesPath = "$HOME/.config/nixpkgs/overlays/home-manager/home-manager/modules";
  };
}

