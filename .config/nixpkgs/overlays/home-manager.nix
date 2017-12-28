self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "f0d207f3807c2111532d361c71047e1883595f3a";
    sha256 = "1cbhkdvnid1w0xmzl922cb3mvvipxgly0zw9vccy346g89yy9vsf";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
