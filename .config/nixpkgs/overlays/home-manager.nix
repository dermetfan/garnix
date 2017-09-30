self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "e9deaf2ca5b414de4c5ed156fb801f05011f617a";
    sha256 = "0zaqdzzwj2fzb7y8i0g0b5v15wwl55i497g579ksf4j01nl7clgi";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

