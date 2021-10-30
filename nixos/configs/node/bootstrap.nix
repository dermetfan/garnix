{ config, lib, pkgs, ... }:

{
  imports = [
    bootstrap/decrypt-secrets.nix
    bootstrap/send-secrets.nix
  ];

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
          type = types.path;
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

    passthru.bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
      ${builtins.readFile bootstrap/setup.sh}

      >&2 echo 'Decrypting bootstrap secrets…'
      ${config.passthru.decrypt-bootstrap-secrets}/bin/decrypt-bootstrap-secrets
      >&2 echo

      >&2 echo 'Sending bootstrap secrets to target machine…'
      ${config.passthru.send-bootstrap-secrets}/bin/send-bootstrap-secrets
    '';
  };
}
