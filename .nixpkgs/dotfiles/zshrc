# include rust/cargo binaries in PATH
typeset -U path
path+=(~/.cargo/bin)
export PATH

alias adb="$ANDROID_HOME/platform-tools/adb"
alias sudoadb="sudo $ANDROID_HOME/platform-tools/adb"

alias diffy="diff -ry --suppress-common-lines"

alias tns="docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb -v \$PWD:/src -v tns-settings:/root/.local/share/.nativescript-cli ashtreecc/nativescript tns"
alias tnsenv="docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb -v \$PWD:/src -v tns-settings:/root/.local/share/.nativescript-cli ashtreecc/nativescript"
alias tnso="docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb -v \$PWD:/src oreng/nativescript tns"

if [ -f ~/.antigen/antigen.zsh ]; then
. ~/.antigen/antigen.zsh
  antigen init ~/.antigenrc
fi
