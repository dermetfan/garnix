{ self, config, lib, pkgs, ... }:

let
  secrets = config.bootstrap.secrets;

  node = self.outputs.deploy.nodes.${config.networking.hostName};

  send = lib.mapAttrs (k: v: {
    local = v.file;
    remote = v.path;

    inherit (v) mode owner group;
    inherit (node) hostname sshUser;
  }) secrets;

  script = pkgs.writeShellScriptBin "send-bootstrap-secrets" (''
    ${builtins.readFile ./setup.sh}
  '' + (lib.concatStrings (
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
  )));
in

{
  passthru.send-bootstrap-secrets = script;
}
