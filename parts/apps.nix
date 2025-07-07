{ self, inputs, ... }:

{
  perSystem = { system, pkgs, ... }: {
    apps = builtins.mapAttrs (_: drv: inputs.flake-utils.lib.mkApp { inherit drv; }) {
      home-manager-shell = inputs.home-manager-shell.lib {
        inherit self system;
        args.extraSpecialArgs.nixosConfig = null;
      };

      decrypt-secrets = pkgs.writeShellApplication {
        name = "decrypt-secrets";
        runtimeInputs = with pkgs; [ rage ];
        text = ''
          shopt -qs globstar failglob

          while getopts f opt; do
              case "$opt" in
                  f) force=1 ;;
                  *) exit 1 ;;
              esac
          done
          shift $((OPTIND - 1))

          identityFile=$(mktemp --tmpdir deployer_ssh_key.XXX)
          trap 'rm "$identityFile"' EXIT

          secrets/askkey >> "$identityFile"
          pass=$(secrets/askpass)

          prefix=secrets
          if [[ -v 1 ]]; then
              prefix="''${1%%/}"
          fi

          for secret in "$prefix"/**/*.age; do
              target="''${secret%.age}"

              if [[ -f "$target" && ! -v force ]]; then
                  >&2 printf 'Skipping %s: already exists\n' "$target"
                  continue
              fi

              >&2 printf 'Writing  %s…\n' "$target"
              # rage reads the password from /dev/tty instead of stdin.
              # https://github.com/str4d/rage/issues/550
              expect <<EOF
          log_user 0
          spawn rage --decrypt --identity "$identityFile" --output "$target" "$secret"
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
          done
        '';
      };

      clean-secrets = pkgs.writeShellApplication {
        name = "clean-secrets";
        text = ''
          shopt -qs globstar

          for secret in secrets/**/*.age; do
              target="''${secret%.age}"

              >&2 printf 'Deleting %s…\n' "$target"
              rm -f "$target"
          done
        '';
      };
    };
  };
}
