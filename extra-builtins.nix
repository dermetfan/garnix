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

        TMP=$(mktemp --tmpdir "$(basename "$PWD").$(basename "$1" .age)".XXX)
        trap 'rm "$TMP"' EXIT

        PASS=$(secrets/askpass)

        # rage reads the password from /dev/tty instead of stdin.
        # https://github.com/str4d/rage/issues/550
        expect <<EOF
        log_user 0
        spawn rage --decrypt --identity secrets/deployer_ssh_ed25519_key --output "$TMP" "$1"
        while {1} {
          expect {
            "Type passphrase for" {
              send "$PASS\n"
              expect "\n"
            }
            eof {
              break
            }
          }
        }
        EOF
      '' + (if nix then ''
        cat "$TMP"
      '' else ''
        nix eval --impure --expr "builtins.readFile $TMP"
      ''))
      (builtins.baseNameOf ./extra-builtins.nix)
      path
    ];
in {
  readSecret = decrypt false;
  importSecret = decrypt true;
}
