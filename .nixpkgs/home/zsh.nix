{ exa }:

{
  target = ".zshrc";
  text = let
    _exa = "${exa}/bin/exa";
  in ''
    # include Cargo binaries in PATH
    typeset -U path
    path+=(~/.cargo/bin)
    export PATH

    if [ -f ~/.antigen/antigen.zsh ]; then
      . ~/.antigen/antigen.zsh
      antigen init ~/.antigenrc
    fi

    alias l="${_exa} -lga"
    alias ll="${_exa} -lg"
    alias diff="diff -r --suppress-common-lines"
  '';
}
