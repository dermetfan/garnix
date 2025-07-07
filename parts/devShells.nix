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

            exec ssh -i "$identityFile" "''${args[@]}"
          '';
        })
        pkgs.expect # needed by extra-builtins-file in NIX_CONFIG
      ];

      NIX_CONFIG = ''
        plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
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
