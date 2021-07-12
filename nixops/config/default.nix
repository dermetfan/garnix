{
  imports = [
    <nixpkgs/nixos/modules/misc/passthru.nix>
    ./nginx.nix
    ./ssmtp.nix
    ./nextcloud.nix
    ./roundcube.nix
    ./minecraft-server.nix
    ./hydra.nix
    ./syncthing.nix
    ./acme.nix
    ./ddclient.nix
  ];

  passthru = {
    domain = "dermetfan.net";

    "nginx.virtualHosts.withSSL" = x: x // {
      enableACME = true;
      sslCertificate = ../../keys/host.crt;
      sslCertificateKey = "/run/keys/host.key";
    };
  };
}
