{ inputs, lib, getSystem, moduleWithSystem, ... } @ parts:

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

      defaults = { name, config, lib, pkgs, ... }: let
        secrets =
          with builtins.tryEval <secrets>;
          if success then value else null;
      in {
        imports = [
          parts.config.flake.nixosModules.default
          (import ./node.nix {
            inherit moduleWithSystem;
            inherit (parts) config;
          })
        ] ++ (
          let path = "${toString secrets}/hosts/${name}/secrets.nix"; in
          lib.optional (secrets != null && builtins.pathExists path) path
        );

        deployment = {
          targetHost =
            if secrets != null
            then lib.fileContents "${toString secrets}/hosts/${name}/yggdrasil/ip"
            else "${name}.hosts.${config.networking.domain}";
          targetUser = "root";
          allowLocalDeployment = true;
        };

        networking.hostName = name;

        # https://github.com/openzfs/zfs/issues/16685#issuecomment-3703930891
        boot.zfs.package = pkgs.zfs_2_4;
      };
    }
  );
}
