{ config, lib, pkgs, ... }:

let
  cfg = config.programs.cargo;
in {
  options.programs.cargo.enable = lib.mkEnableOption "cargo";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.cargo ];

    programs = {
      bash.initExtra = ''
        PATH="$PATH":~/.cargo/bin
      '';
      zsh.initExtra = ''
        path+=(~/.cargo/bin)
      '';
      fish.shellInit = ''
        fish_add_path ~/.cargo/bin
      '';
    };
  };
}
