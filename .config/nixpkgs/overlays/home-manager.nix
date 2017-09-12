self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "379e2c694b9cb3f9a26e9620a36fb018f0b4ca21";
    sha256 = "167z5r00rflqrn66fqy0fpi4ikrwjr3h13bpg2z73jb8vl2rkl7q";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

