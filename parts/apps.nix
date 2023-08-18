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
              rage --decrypt \
                  --identity secrets/deployer_ssh_ed25519_key \
                  --output "$target" \
                  "$secret"
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
