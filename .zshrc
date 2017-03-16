# include Cargo binaries in PATH
typeset -U path
path+=(~/.cargo/bin)
export PATH

alias diffy="diff -ry --suppress-common-lines"

if [ -f ~/.antigen/antigen.zsh ]; then
  . ~/.antigen/antigen.zsh
  antigen init ~/.antigenrc
fi
