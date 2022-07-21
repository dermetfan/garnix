{
  perSystem = { system, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      SSH_ASKPASS_REQUIRE = "prefer";
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
