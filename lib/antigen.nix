{ zsh, curl, writeScript
, fetchUrl ? "https://cdn.rawgit.com/zsh-users/antigen/v2.2.1/bin/antigen.zsh"
, sha512 ? "f1551060bf9756c3b7881a22584986a0528d9b3c5acfedb9ea912d04901419db537f8c8e15fdd6539aa26a91175a59b7534bd83a03268db9f19cadc0331a523e" }:

let
  script = let
    _curl = "${curl}/bin/curl";
  in writeScript "antigen-install.zsh" ''
    #! ${zsh}/bin/zsh

    antigen="$HOME/.antigen/antigen.zsh"

    installed() { return `[[ -f $antigen ]]` }

    ask() {
      printf "$1 [y/N] "
      read
      return `[[ "$REPLY" = y || "$REPLY" = Y ]]`
    }

    if ! installed && ask >&2 "Missing $antigen. Install?"; then
      ${_curl} ${fetchUrl} > /tmp/antigen.zsh

      if ! `echo "${sha512} /tmp/antigen.zsh" | sha512sum -c --status`; then
        echo >&2 "Abort: wrong checksum!"
        echo >&2 "downloaded from: ${fetchUrl}"
        echo >&2 "Expected sha512: ${sha512}"
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
