let
  deployers = map builtins.readFile [
    ./deployer_ssh_ed25519_key.pub
  ];

  host = name: builtins.readFile hosts/${name}/ssh_host_ed25519_key.pub;

  service = name: "services/${name}.age";

  privateForHost = hostName: secrets:
    builtins.listToAttrs (
      map (secret: {
        name = "hosts/${hostName}/${secret}.age";
        value.publicKeys = [ (host hostName) ];
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

builtins.listToAttrs (
  map (k: {
    name = "${k}.age";
    value.publicKeys = deployers;
  }) (import hosts/ssh-keys.nix)
) //

{
  ${service "github"}.publicKeys = deployers;
} //

servicesForHosts {
  "ceph.mon..keyring" = [ "node-2" "node-0" "laptop" ];
  "ceph.client.admin.keyring" = [ "node-2" ];
  "ceph.client.node.keyring" = [ "node-2" ];
  "ceph.client.dermetfan.keyring" = [ "laptop" ];
  "ceph.client.diemetfan.keyring" = [ "thinkpad" ];

  "cache.sec" = [ "node-0" ];

  "nextcloud" = [ "node-0" ];

  "ssmtp" = [ "node-0" ];
} //

privateForHost "laptop" [
  "yggdrasil/key.conf"
  "secrets.nix"
] //

privateForHost "thinkpad" [
  "yggdrasil/key.conf"
] //

privateForHost "node-0" [
  "yggdrasil/key.conf"
  "freedns"
] //

privateForHost "node-2" [
  "yggdrasil/key.conf"
]
