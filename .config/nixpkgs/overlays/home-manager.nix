self: super:

{
  home-manager = import ../home-manager { pkgs = self; };
}
