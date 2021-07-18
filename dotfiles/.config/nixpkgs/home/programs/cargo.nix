{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.cargo;
in {
  options       .programs.cargo.enable = lib.mkEnableOption "cargo";
  options.config.programs.cargo.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.cargo.enable;
    defaultText = "<option>config.programs.cargo.enable</option>";
    description = "Whether to configure Cargo.";
  };

  config = lib.mkMerge [
    { home.packages = lib.optional config.programs.cargo.enable pkgs.cargo; }

    (lib.mkIf cfg.enable {
      home.file.".cargo/config".text = ''
        [cargo-new]
        name = "Robin Stumm"
        email = "serverkorken@gmail.com"
        vcs = "hg"
      '';

      programs.zsh.initExtra = ''
        path+=(~/.cargo/bin)
      '';
    })
  ];
}
