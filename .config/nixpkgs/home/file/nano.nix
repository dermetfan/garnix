{ fetchFromGitHub, ... }:

let nanorcs = fetchFromGitHub {
  owner = "scopatz";
  repo = "nanorc";
  rev = "b394ee16e160fe8fdb3a7711f167573e7841ce3a";
  sha256 = "1ni2qy5qmp2bvprasgw0p7pha1f0nmjkh77n2qql98krwmiaymc5";
}; in [
  {
    target = ".nano";
    source = nanorcs;
  }
  {
    target = ".nanorc";
    source = "${nanorcs}/nanorc";
  }
]
