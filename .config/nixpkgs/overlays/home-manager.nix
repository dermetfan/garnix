self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "54043df8fbb07e34fac69d103873823c050e4a6b";
    sha256 = "0qwlbvdwmg4k3fbxlsh0xdsmjc4w6avysznd4khch9y9yj5hf1rv";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
