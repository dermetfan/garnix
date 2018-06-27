self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "0d3f9ba913dca444a3cb3ba566575196ed90d92c";
    sha256 = "1lr0akmyjfffm4mrz52h5a4cfy8w9jszn6iwi4x7cib6ri91s52k";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
