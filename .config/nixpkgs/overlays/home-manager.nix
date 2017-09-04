self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "721f924e151d5c2195ac55c5af39485023cb7b94";
    sha256 = "1sw3i1kq5hy8wd7hw1kcnsfrssqpklldv2hia28s2601wc2x97m7";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

