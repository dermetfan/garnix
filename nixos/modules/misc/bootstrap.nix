{ self, config, lib, pkgs, ... }:

let
  cfg = config.bootstrap;
in {
  options.bootstrap.secrets = with lib; mkOption {
    type = types.attrsOf (types.submodule (sub: {
      options = let
        secretsDir = "secrets/hosts/nodes/${lib.removePrefix "node-" config.networking.hostName}/";
      in {
        file = mkOption {
          type = types.str;
          default = secretsDir + (
            lib.removePrefix
              (toString ../../..)
              sub.config._module.args.name
          );
        };
        path = mkOption {
          type = with types; nullOr path;
          description = ''
            The target path on the target host.
            Set to <code>null</code> to not send this secret.
          '';
          default = "/run/secrets/" + (
            lib.removePrefix
              secretsDir
              sub.config.file
          );
        };
        owner = mkOption {
          type = types.ints.unsigned;
          default = 0;
        };
        group = mkOption {
          type = types.ints.unsigned;
          default = 0;
        };
        mode = mkOption {
          type = types.strMatching "[[:digit:]]{4}";
          default = "0400";
        };
      };
    }));
    default = {};
  };

  config = {
    bootstrap.secrets = lib.listToAttrs (
      map ({ path, ... }:
        lib.nameValuePair
          (builtins.baseNameOf path)
          { inherit path; }
      ) config.services.openssh.hostKeys
    );

    passthru = let
      setup = ''
        if [[ ! -f flake.nix ]]; then
            >&2 echo 'This script must be run from the repo root.'
            exit 1
        fi
        set -e
      '';
    in {
      bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
        ${setup}

        >&2 echo 'Decrypting bootstrap secrets…'
        ${config.passthru.bootstrap-decrypt-secrets}/bin/bootstrap-decrypt-secrets
        >&2 echo

        >&2 echo 'Sending bootstrap secrets to target machine…'
        ${config.passthru.bootstrap-send-secrets}/bin/bootstrap-send-secrets
      '';

      bootstrap-decrypt-secrets = pkgs.writeShellScriptBin "bootstrap-decrypt-secrets" ''
        ${setup}

        if [[ ! -f secrets/deployer_ssh_ed25519_key ]]; then
          >&2 echo 'missing secrets/deployer_ssh_ed25519_key'
          exit 1
        fi

        for path in ${lib.escapeShellArgs (
          lib.catAttrs "file" (lib.attrValues cfg.secrets)
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

      bootstrap-send-secrets = let
        node = self.outputs.deploy.nodes.${config.networking.hostName};

        secrets = lib.filterAttrs
          (k: v: v.path != null)
          cfg.secrets;

        send = lib.mapAttrs (k: v: {
          local = v.file;
          remote = v.path;

          inherit (v) mode owner group;
          inherit (node) hostname sshUser;
        }) secrets;
      in pkgs.writeShellScriptBin "bootstrap-send-secrets" (
        setup + lib.concatStrings (
          lib.mapAttrsToList (k: v: with v; ''
            ${pkgs.rsync}/bin/rsync --mkpath --info name2,progress2 \
              -e "${pkgs.openssh}/bin/ssh -l ${sshUser} -i ''${SSH_ID:-secrets/deployer_ssh_ed25519_key}" \
              --perms --chmod ${mode} \
              ${""/* cannot use `--chown ${owner}:${group}` if receiver is on non-posix shell like fish */} \
              --usermap $(stat -c %u ${local}):${owner} --groupmap $(stat -c %g ${local}):${owner} \
              ${local} ${hostname}:${remote} || \
              if [[ -z "$SSH_ID" ]]; then
                >&2 echo 'You can set the environment variable SSH_ID to use another identity.'
              fi
          '') (lib.mapAttrsRecursive (p: lib.escapeShellArg) send)
        )
      );
    };
  };
}
