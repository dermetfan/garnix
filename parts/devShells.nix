{
  perSystem = { inputs', pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs'.agenix.packages.default
        inputs'.colmena.packages.colmena
        pkgs.rage
        (pkgs.writeShellApplication {
          # Colmena passes `-o BatchMode=yes` on the CLI.
          # We want to disable that so that SSH_ASKPASS can be used.
          name = "ssh";
          runtimeInputs = with pkgs; [ openssh ];
          text = ''
            declare -a args
            for arg in "$@"; do
                if [[ "$arg" = BatchMode=yes ]]; then
                    args+=(BatchMode=no)
                    continue
                fi
                args+=("$arg")
            done
            exec ssh "''${args[@]}"
          '';
        })
      ];

      SSH_CONFIG_FILE = builtins.toFile "ssh_config" ''
        IdentityFile secrets/deployer_ssh_ed25519_key
      '';

      SSH_ASKPASS_REQUIRE = "force";
      SSH_ASKPASS = "secrets/askpass";

      shellHook = ''
        cd $(git rev-parse --show-toplevel)

        if [[ ! -x "$SSH_ASKPASS" ]]; then
            >&2 echo    "$SSH_ASKPASS"' is missing or not executable.'
            >&2 echo    'Please place a script there that prints the key for'
            >&2 echo -e '\tsecrets/deployer_ssh_ed25519_key'
        fi

        export NIX_PATH="''${NIX_PATH:-}''${NIX_PATH:+:}secrets=$PWD/secrets"
      '';
    };
  };
}
