{ self, inputs, ... }:

{
  perSystem = { config, lib, system, inputs', ... }: {
    apps = lib.genAttrs [ "deploy-rs" ] (input:
      inputs'.${input}.apps.default or
      inputs'.${input}.defaultApp
    ) // {
      inherit (inputs'.agenix.apps) ragenix;

      home-manager-shell = inputs.flake-utils.lib.mkApp {
        drv = inputs.home-manager-shell.lib {
          inherit self system;
          args.extraSpecialArgs.nixosConfig = null;
        };
      };

      default = config.apps.deploy-rs;
    };
  };
}
