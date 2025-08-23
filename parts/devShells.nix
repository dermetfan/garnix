{
  perSystem = { inputs', pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs'.agenix.packages.default
        inputs'.colmena.packages.colmena
        pkgs.rage
        (pkgs.writeShellApplication {
          name = "ssh";
          runtimeInputs = with pkgs; [ openssh ];
          text = ''
            identityFile=$(mktemp --tmpdir deployer_ssh_key.XXX)

            # An EXIT trap is not enough as colmena kills SSH on failure.
            nohup "$BASH" -s -- "$$" "$identityFile" &>/dev/null <<'EOF' &
            tail --pid "$1" --follow /dev/null
            rm "$2"
            EOF

            "$(dirname "$RULES")"/askkey >> "$identityFile"

            # Colmena passes `-o BatchMode=yes` on the CLI.
            # We want to disable that so that SSH_ASKPASS can be used.
            declare -a args
            for arg in "$@"; do
                if [[ "$arg" = BatchMode=yes ]]; then
                    args+=(BatchMode=no)
                    continue
                fi
                args+=("$arg")
            done

            declare -a iArgs
            for defaultIdentityFile in \
              ~/.ssh/id_rsa \
              ~/.ssh/id_ecdsa \
              ~/.ssh/id_ecdsa_sk \
              ~/.ssh/id_ed25519 \
              ~/.ssh/id_ed25519_sk
            do
              if [[ -e "$defaultIdentityFile" ]]; then
                iArgs+=(-i "$defaultIdentityFile")
              fi
            done

            exec ssh -i "$identityFile" "''${iArgs[@]}" "''${args[@]}"
          '';
        })
        pkgs.expect # needed by extra-builtins-file in NIX_CONFIG
      ];

      NIX_CONFIG = let
        # TODO Remove once fixed upstream.
        # https://github.com/shlevy/nix-plugins/issues/20#issuecomment-2907104550
        nix-plugins = pkgs.nix-plugins.overrideAttrs (oldAttrs: {
          buildInputs = map
            (pkg: if pkg.pname or null != "nix" then pkg else pkgs.nix)
            (oldAttrs.buildInputs or []);
          patches = oldAttrs.patches or [] ++ [
            (builtins.toFile "20.patch" ''
              diff a/extra-builtins.cc b/extra-builtins.cc
              --- a/extra-builtins.cc
              +++ b/extra-builtins.cc
              @@ -1,10 +1,10 @@
              -#include <config.h>
              -#include <primops.hh>
              -#include <globals.hh>
              -#include <config-global.hh>
              -#include <eval-settings.hh>
              -#include <common-eval-args.hh>
              -#include <filtering-source-accessor.hh>
              +#include <nix/cmd/common-eval-args.hh>
              +#include <nix/expr/eval-settings.hh>
              +#include <nix/expr/primops.hh>
              +#include <nix/fetchers/filtering-source-accessor.hh>
              +#include <nix/store/globals.hh>
              +#include <nix/util/configuration.hh>
              +#include <nix/util/config-global.hh>
            '')
          ];
        });
      in ''
        plugin-files = ${nix-plugins}/lib/nix/plugins
        extra-builtins-file = ${../extra-builtins.nix}
      '';

      SSH_ASKPASS_REQUIRE = "force";

      shellHook = ''
        cd "$(git rev-parse --show-toplevel)"

        export RULES="$PWD/secrets/secrets.nix"
        secrets=$(dirname "$RULES")

        if [[ ! -x "$secrets"/askkey ]]; then
            >&2 echo "$secrets"'/askkey is missing or not executable.'
            >&2 echo 'Please place a script there that prints the deployer SSH key.'
        fi

        export SSH_ASKPASS="$secrets"/askpass
        if [[ ! -x "$SSH_ASKPASS" ]]; then
            >&2 echo "$SSH_ASKPASS"' is missing or not executable.'
            >&2 echo 'Please place a script there that prints the key for the deployer SSH key.'
        fi
      '';
    };
  };
}
