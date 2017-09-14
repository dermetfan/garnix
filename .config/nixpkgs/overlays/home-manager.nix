self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "6ecf9e091c53d592edeb202378a5b5c920dfde55";
    sha256 = "0sdmmfk2dvmn0l6k0gp6027jxlv4w4dvwd3yh8lnb5hv503xsmgb";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

