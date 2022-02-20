{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.nano;
in {
  options.profiles.dermetfan.programs.nano.enable = lib.mkEnableOption "nano" // {
    default = config.programs.nano.enable or false;
  };

  config.home.file = lib.mkIf cfg.enable (
    let
      nanorcs = pkgs.fetchFromGitHub {
        owner = "scopatz";
        repo = "nanorc";
        rev = "b394ee16e160fe8fdb3a7711f167573e7841ce3a";
        sha256 = "1ni2qy5qmp2bvprasgw0p7pha1f0nmjkh77n2qql98krwmiaymc5";
      };
    in {
      ".nano"  .source = nanorcs;
      ".nanorc".source = "${nanorcs}/nanorc";
    }
  );
}
