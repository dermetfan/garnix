{ inputs, options, ... }:

{
  # Needed by optnix to evaluate option values.
  debug = true;

  perSystem = { inputs', lib, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs'.agenix.packages.default
        inputs'.colmena.packages.colmena
        pkgs.rage
        (inputs.wrapper-manager.lib.wrapWith pkgs {
          basePackage = inputs'.optnix.packages.default;
          prependFlags = lib.cli.toGNUCommandLine {} {
            config = (pkgs.formats.toml {}).generate "optnix.toml" rec {
              default_scope = "flake-parts";
              scopes.${default_scope} = {
                description = "${default_scope}: garnix";
                options-list-file = (inputs.optnix.mkLib pkgs).mkOptionsList { inherit options; };
                evaluator = "nix eval .#debug.config.{{ .Option }}";
              };
            };
          };
        })
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

      NIX_CONFIG = ''
        plugin-files = ${pkgs.nix-plugins.override {
          # This compiles nix-plugins against the Nix version
          # that is currently the default in NixOS.
          nixComponents = let
            inherit (lib.versions) major minor;
            inherit (pkgs.nix) version;
          in pkgs.nixVersions."nixComponents_${major version}_${minor version}";
        }}/lib/nix/plugins
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
