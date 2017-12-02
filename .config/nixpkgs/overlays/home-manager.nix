self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "c023b0532a7c9761840aefc0e059b2e424fb1520";
    sha256 = "1klsydx3cv0jcra2viczqa8y94xx4s1wfp6ibpbga6s1796y9nql";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
