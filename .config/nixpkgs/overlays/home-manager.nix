self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "3aca8a938c36e49787e53b58cfa74214f407da40";
    sha256 = "17fddwjdfx9zbvs891ympnnzgsyw79jx3phj64s4xamj72mz5cfj";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

