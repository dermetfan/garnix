self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "52256d7a73f5849014014451d28935b810ee03f4";
    sha256 = "1ly10bw0qspc8dip9s251lss12m8myq3mbppxyld70mn3q06vl5l";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

