self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "e1bceb2adb046d56b437d6c2c48fc717b0b028e3";
    sha256 = "19smd3y6z2yvp6agmdk7li3pji4vpnvj899f898fgp4mp3b3q2j0";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

