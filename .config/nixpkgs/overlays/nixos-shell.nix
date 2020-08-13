self: super: {
  nixos-shell = super.fetchFromGitHub {
    owner = "Mic92";
    repo = "nixos-shell";
    rev = "60e8f7f41e5ac1ec7acf1ec2fc2fbdad38d78111";
    sha256 = "0mc4cn4bkh2frkiswp29kwy033jyggkfgflmgrw5dfp2d0l06j4l";
  };
}
