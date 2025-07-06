{ inputs, lib, getSystem, ... } @ parts:

{
  flake.colmenaHive = let
    nodes = builtins.mapAttrs (k: v: v parts) (lib.filesystem.importDirToAttrsWithOpts { doImport = true; } ./nodes);
  in inputs.colmena.lib.makeHive (
    builtins.mapAttrs (_: node: {
      imports = map
        (module: (
          if builtins.isPath module
          then import module
          else module
        ) parts)
        (node.modules or []);
    }) nodes // {
      meta = {
        allowApplyAll = false;

        nixpkgs = (getSystem "x86_64-linux").legacyPackages;

        nodeNixpkgs = builtins.mapAttrs (_: node: node.nodeNixpkgs) nodes;

        specialArgs = { inherit lib; };
      };

      defaults = { name, config, lib, ... }: {
        imports = [
          parts.config.flake.nixosModules.default
          (import ./node.nix parts)
        ] ++ (
          let path = ../../secrets/hosts/${name}/secrets.nix.age; in
          lib.optional (builtins.pathExists path) (builtins.extraBuiltins.importSecret path)
        );

        deployment = {
          targetHost = let
            path = ../../secrets/hosts/${name}/yggdrasil/ip;
          in
            if builtins.pathExists path
            then lib.fileContents path
            else "${name}.hosts.${config.networking.domain}";
          targetUser = "root";
          allowLocalDeployment = true;
        };

        networking.hostName = name;
      };
    }
  );
}
