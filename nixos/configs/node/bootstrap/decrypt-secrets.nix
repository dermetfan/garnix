{ config, lib, pkgs, ... }:

let
  secrets = config.bootstrap.secrets;

  script = pkgs.writeShellScriptBin "decrypt-bootstrap-secrets" ''
    ${builtins.readFile ./setup.sh}

    if [[ ! -f secrets/deployer_ssh_ed25519_key ]]; then
      >&2 echo 'missing secrets/deployer_ssh_ed25519_key'
      exit 1
    fi

    for path in ${lib.escapeShellArgs (
      lib.catAttrs "file" (lib.attrValues secrets)
    )}; do
      basename=$(basename "$path")
      if [[ -s "$path" ]]; then
        >&2 echo "$basename skipped (exists and not empty)"
        continue
      fi
      >&2 echo "$basename"
      ${pkgs.rage}/bin/rage -d -i secrets/deployer_ssh_ed25519_key "$path".age > "$path"
    done
  '';
in

{
  passthru.decrypt-bootstrap-secrets = script;
}
