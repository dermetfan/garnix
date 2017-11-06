self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "fc3e82584bda579739f01b57e5f31adea2bce593";
    sha256 = "0fgqx2zyj8643dwskra7hlda9f3gzavdl57dg4hapcxjw1qgljfz";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

