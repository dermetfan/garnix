{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.antigen;
in {
  options       .programs.antigen.enable = lib.mkEnableOption "antigen";
  options.config.programs.antigen.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.antigen.enable;
    defaultText = "<option>config.programs.antigen.enable</option>";
    description = "Whether to configure antigen.";
  };

  config.programs.zsh.initExtra = lib.optionalString config.programs.antigen.enable ''
    . ~/.antigen/antigen.zsh
    antigen init ~/.antigenrc
  '';
  config.home.file = lib.mkIf cfg.enable {
    ".antigenrc".text = ''
      antigen use oh-my-zsh

      antigen theme nicoulaj

      antigen bundles <<EOF
        zsh-users/zsh-syntax-highlighting
        colored-man-pages
        dircycle
        extract
        history
        sudo
        mosh
        tmux
        urltools
        gradle
        mercurial
        git
        nyan
      EOF
      antigen bundle web-search; alias open_command=xdg-open

      antigen apply
    '';

    ".antigen/antigen.zsh".source = pkgs.fetchurl {
      url = https://cdn.rawgit.com/zsh-users/antigen/v2.2.1/bin/antigen.zsh;
      sha512 = "f1551060bf9756c3b7881a22584986a0528d9b3c5acfedb9ea912d04901419db537f8c8e15fdd6539aa26a91175a59b7534bd83a03268db9f19cadc0331a523e";
    };
  };
}
