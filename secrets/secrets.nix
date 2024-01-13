let
  removeNewlines = builtins.replaceStrings [ "\n" ] [ "" ];
  readKey = file: removeNewlines (builtins.readFile file);

  deployers = map readKey [
    ./deployer_ssh_ed25519_key.pub
  ];

  withDeployers = builtins.mapAttrs (k: v: v // {
    publicKeys = v.publicKeys or [] ++ deployers;
  });

  host = name: readKey hosts/${name}/ssh_host_ed25519_key.pub;
  user = name: readKey users/${name}/id_ed25519.pub;

  service = name: "services/${name}.age";

  privateForHost = hostName: secrets:
    builtins.listToAttrs (
      map (secret: {
        name = "hosts/${hostName}/${secret}.age";
        value.publicKeys = [ (host hostName) ];
      }) secrets
    );

  privateForUser = userName: secrets:
    builtins.listToAttrs (
      map (secret: {
        name = "users/${userName}/${secret}.age";
        value.publicKeys = [ (user userName) ];
      }) secrets
    );

  servicesForHosts = kv:
    builtins.listToAttrs (
      map (k: {
        name = service k;
        value.publicKeys = map host kv.${k};
      }) (builtins.attrNames kv)
    );
in

withDeployers (
  builtins.listToAttrs (map (k: {
    name = "${k}.age";
    value = {};
  }) (import hosts/ssh-keys.nix)) //

  {
    ${service "github"} = {};
  } //

  privateForUser "dermetfan" [
    "nix-access-tokens"
  ] //

  privateForHost "laptop" [
    "yggdrasil/key.conf"
    "freedns"
    "secrets.nix"
  ] //

  privateForHost "thinkpad" [
    "yggdrasil/key.conf"
    "freedns"
  ] //

  privateForHost "node-0" [
    "yggdrasil/key.conf"
    "freedns"
  ] //

  privateForHost "node-3" [
    "yggdrasil/key.conf"
  ] //

  servicesForHosts {
    "cache.sec" = [ "node-0" ];

    "ssmtp" = [ "node-0" ];

    filestash = [ "node-3" ];
  }
)
