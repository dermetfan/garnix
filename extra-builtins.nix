{exec, ...}: let
  decrypt = nix: path:
    assert builtins.isPath path;
    exec [
      "/usr/bin/env"
      "bash"
      "-c"
      (''
        set -euo pipefail

        cd "$(git rev-parse --show-toplevel)"

        if ! [[ -e "$1" ]]; then
          >&2 echo 'Secret not found: '"$1"
          exit 1
        fi

        identityFile=$(mktemp --tmpdir deployer_ssh_key.XXX)
        tmp=$(mktemp --tmpdir "$(basename "$PWD").$(basename "$1" .age)".XXX)
        trap 'rm "$identityFile" "$tmp"' EXIT

        secrets/askkey >> "$identityFile"
        pass=$(secrets/askpass)

        # rage reads the password from /dev/tty instead of stdin.
        # https://github.com/str4d/rage/issues/550
        expect <<EOF
        log_user 0
        spawn rage --decrypt --identity "$identityFile" --output "$tmp" "$1"
        while {1} {
          expect {
            "Type passphrase for" {
              send "$pass\n"
              expect "\n"
            }
            eof {
              break
            }
          }
        }
        EOF
      '' + (if nix then ''
        cat "$tmp"
      '' else ''
        nix eval --impure --expr "builtins.readFile $tmp"
      ''))
      (builtins.baseNameOf ./extra-builtins.nix)
      path
    ];
in {
  readSecret = decrypt false;
  importSecret = decrypt true;
}
