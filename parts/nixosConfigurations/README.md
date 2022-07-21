# How To Bootstrap

SSH host keys have to be present on the target machines so they are able to decrypt their secrets with agenix.
Those SSH host keys are stored in age-encrypted form under `../../secrets/hosts`.

Run `nix run .#nixosConfigurations.<host>.config.passthru.bootstrap` to decrypt them and copy their cleartext to the target machine.
