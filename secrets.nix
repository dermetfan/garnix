let
  deployers = map builtins.readFile [
    secrets/deployer_ssh_ed25519_key.pub
  ];

  hosts = names:
    map (name:
      builtins.readFile secrets/hosts/${name}/ssh_host_ed25519_key.pub
    ) names;

  services = names:
    map (name: "services/${name}") names;

  encryptFor = publicKeys: secrets:
    builtins.listToAttrs (map (secret: {
      name = "secrets/${secret}.age";
      value.publicKeys = publicKeys ++ deployers;
    }) secrets);
in

encryptFor [] (import secrets/hosts/key-list.nix) //

encryptFor (hosts [ "nodes/0" ]) (services [
  "cache.sec"
  "nextcloud"
  "ssmtp"
])
