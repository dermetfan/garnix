let
  inherit (
    let
      flakeLock = builtins.fromJSON (builtins.readFile ../flake.lock);
      rootNode = flakeLock.nodes.${flakeLock.root};
      nixpkgsNode = flakeLock.nodes.${rootNode.inputs.nixpkgs};
    in
      builtins.getFlake (with nixpkgsNode.locked; "${type}:${owner}/${repo}/${rev}")
  ) lib;

  recipients = {
    deployer = lib.fileContents ./deployer_ssh_ed25519_key.pub;
    host = name: lib.fileContents hosts/${name}/ssh_host_ed25519_key.pub;
    user = name: lib.fileContents users/${name}/id_ed25519.pub;
  };

  secrets = {
    service = secret: "services/${secret}.age";
    host = hostName: secret: "hosts/${hostName}/${secret}.age";
    user = userName: secret: "users/${userName}/${secret}.age";
  };

  withDeployer = builtins.mapAttrs (_: v: v // {
    publicKeys = v.publicKeys or [] ++ [ recipients.deployer ];
  });

  selfSecrets = kind: name: secretNames:
    assert builtins.any (x: x == kind) ["user" "host"];
    builtins.listToAttrs (
      map (secretName:
        lib.nameValuePair
        (secrets.${kind} name secretName)
        { publicKeys = [ (recipients.${kind} name) ]; }
      ) secretNames
    );

  hostSecrets = selfSecrets "host";
  userSecrets = selfSecrets "user";

  serviceSecretsForHosts = attrs:
    lib.mapAttrs' (secret: hosts:
      lib.nameValuePair
      (secrets.service secret)
      { publicKeys = map recipients.host hosts; }
    ) attrs;
in withDeployer (
  lib.genAttrs (
    lib.pipe ./hosts [
      lib.filesystem.listFilesRecursive
      (map toString)
      (map (lib.removePrefix (toString ./. + "/")))
      (builtins.filter (path:
        builtins.match "^(initrd_)?ssh_host_[[:alnum:]]+_key.pub$" (builtins.baseNameOf path) != null
      ))
      (map (lib.removeSuffix ".pub"))
      (map (key: "${key}.age"))
    ]
    ++ [
      (secrets.service "github")
      (secrets.host "laptop" "secrets.nix")
      (secrets.host "muttop" "secrets.nix")
    ]
  ) (_: {}) //

  userSecrets "dermetfan" [
    "nix-access-tokens"
  ] //

  hostSecrets "laptop" [
    "yggdrasil/key.conf"
    "freedns"
  ] //

  hostSecrets "muttop" [
    "yggdrasil/key.conf"
  ] //

  hostSecrets "node-0" [
    "yggdrasil/key.conf"
    "freedns"
  ] //

  hostSecrets "node-3" [
    "yggdrasil/key.conf"
  ] //

  serviceSecretsForHosts {
    "cache.sec" = [ "node-0" ];

    "roundcube-google-oauth2-client-secret" = [ "node-3" ];

    "authelia/jwt" = [ "node-3" ];
    "authelia/storage" = [ "node-3" ];
    "authelia/users.json" = [ "node-3" ];
  }
)
