let
  deployers = map builtins.readFile [
    ./deployer_ssh_ed25519_key.pub
  ];

  hosts = names:
    map (name:
      builtins.readFile hosts/${name}/ssh_host_ed25519_key.pub
    ) names;

  services = names:
    map (name: "services/${name}") names;

  encryptFor = publicKeys: secrets:
    builtins.listToAttrs (map (secret: {
      name = "${secret}.age";
      value.publicKeys = publicKeys ++ deployers;
    }) secrets);

  encryptHostSecrets = host: secrets:
    encryptFor (hosts [ host ]) (
      map (secret:
        "hosts/${host}/${secret}"
      ) secrets
    );
in

encryptFor [] (import hosts/ssh-keys.nix) //

encryptHostSecrets "node-0" [ "freedns" ] //

encryptHostSecrets "node-2" [
  "freedns"
  "yggdrasil/keys.conf"
] //

encryptFor (hosts [ "node-0" ]) (services [
  "cache.sec"
  "nextcloud"
  "ssmtp"
])
