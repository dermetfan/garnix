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

withDeployers (
  builtins.listToAttrs (map (k: {
    name = "${k}.age";
    value = {};
  }) (import hosts/ssh-keys.nix)) //

  {
    ${service "github"} = {};
    ${service "ceph.client.admin.keyring"} = {};
  } //

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

  privateForHost "node-2" [
    "yggdrasil/key.conf"
  ] //

  privateForHost "node-3" [
    "yggdrasil/key.conf"
  ] //

  servicesForHosts {
    "ceph.mgr.a.keyring" = [ "node-2" ];
    "ceph.mds.a.keyring" = [ "node-2" ];
    "ceph.mgr.b.keyring" = [ "node-0" ];
    "ceph.mds.b.keyring" = [ "node-0" ];
    "ceph.mgr.c.keyring" = [ "node-3" ];
    "ceph.mds.c.keyring" = [ "node-3" ];
    "ceph.client.dermetfan.keyring" = [ "laptop" ];
    "ceph.client.diemetfan.keyring" = [ "thinkpad" ];
    "ceph.client.mutmetfan.keyring" = [ "node-0" ];
    "ceph.client.roundcube.keyring" = [ "node-2" ];

    "cache.sec" = [ "node-0" ];

    "ssmtp" = [ "node-0" ];
  }
)
