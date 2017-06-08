{ systemConfig, lib, ... }:

{
  target = ".zshrc";
  text = ''
    # include Cargo binaries in PATH
    typeset -U path
    path+=(~/.cargo/bin)
    export PATH

    if [ -f ~/.antigen/antigen.zsh ]; then
      . ~/.antigen/antigen.zsh
      antigen init ~/.antigenrc
    fi

    alias l="exa -lga"
    alias ll="exa -lg"
    alias diff="diff -r --suppress-common-lines"
  '';
}
