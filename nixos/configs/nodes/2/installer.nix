{
  imports = [ ./network.nix ];

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../secrets/deployer_ssh_ed25519_key.pub
  ];
}
