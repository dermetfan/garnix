{ zsh, curl, writeScript,
  fetchUrl ? "https://cdn.rawgit.com/zsh-users/antigen/v1.3.1/bin/antigen.zsh",
  sha512 ? "a37f5165f41dd1db9d604e8182cc931e3ffce832cf341fce9a35796a5c3dcbb476ed7d6e6e9c8c773905427af77dbe8bdbb18f16e18b63563c6e460e102096f3" }:

let
  script = writeScript "antigen-install.zsh" ''
    #!${zsh}/bin/zsh

    antigen="$HOME/.antigen/antigen.zsh"
    url="${fetchUrl}"
    checksum="${sha512}"

    installed() { return `[ -f $antigen ]` }

    ask() {
      printf "$1 [y/N] "
      read answer
      return `[ "$answer" = y ] || [ "$answer" = Y ]`
    }

    if ! installed && ask >&2 "Missing $antigen. Install?"; then
      ${curl}/bin/curl $url > /tmp/antigen.zsh

      if ! `echo "$checksum /tmp/antigen.zsh" | sha512sum -c --status`; then
        echo >&2 "Abort: wrong checksum!"
        echo >&2 "downloaded from: $url"
        echo >&2 "Expected sha512: $checksum"
        echo >&2 "Actual   sha512: `sha512sum /tmp/antigen.zsh | cut -d ' ' -f 1`"
        rm -f /tmp/antigen.zsh
      else
        mkdir -p `dirname $antigen`
        mv /tmp/antigen.zsh $antigen
        echo >&2 "Installed antigen."
      fi

      if ! installed; then
        echo >&2 "Failed to install antigen!"
      fi
    fi
  '';
in "${script}"
