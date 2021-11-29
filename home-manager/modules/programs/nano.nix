{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.nano;
in {
  options       .programs.nano.enable = lib.mkEnableOption "nano";
  options.config.programs.nano.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.nano.enable;
    defaultText = "<option>programs.nano.enable</option>";
    description = "Whether to configure nano.";
  };

  config.home.packages = lib.optional config.programs.nano.enable pkgs.nano;
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
