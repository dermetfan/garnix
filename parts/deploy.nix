{ inputs, config, ... }:

{
  flake.deploy = {
    nodes = builtins.mapAttrs (k: v: {
      profiles.system.path = inputs.deploy-rs.lib.${v.pkgs.system}.activate.nixos v;
      sshUser = "root";
      user = "root";
      hostname = "${k}.hosts.${v.config.networking.domain}";
    }) config.flake.nixosConfigurations;

    sshOpts = [ "-i" "secrets/deployer_ssh_ed25519_key" ];
  };

  perSystem = { system, ... }: {
    checks = inputs.deploy-rs.lib.${system}.deployChecks config.flake.deploy;
  };
}
