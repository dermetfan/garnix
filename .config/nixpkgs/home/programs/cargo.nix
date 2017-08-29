{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.cargo;
in {
  options.config.programs.cargo.enable = lib.mkEnableOption "cargo";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.cargo ];

      file.".cargo/config".text = ''
        [cargo-new]
        name = "Robin Stumm"
        email = "serverkorken@gmail.com"
        vcs = "hg"
      '';
    };

    programs.zsh.initExtra = ''
      path+=(~/.cargo/bin)
    '';
  };
}
