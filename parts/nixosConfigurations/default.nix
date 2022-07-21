{ inputs, config, lib, ... } @ parts:

{
  flake.nixosConfigurations = builtins.mapAttrs
    (k: v:
      let args = import v parts; in
      (args.nixpkgs or inputs.nixpkgs).lib.nixosSystem (removeAttrs args [ "nixpkgs" ] // {
        specialArgs = { inherit lib; } // args.specialArgs or {};
        modules =
          (map
            (part: (
              if builtins.isPath part
              then import part
              else part
            ) parts)
            (args.modules or [])
          ) ++
          [
            config.flake.nixosModules.default
            ({ lib, ... }: {
              nixpkgs.pkgs = lib.mkDefault config.flake.legacyPackages.${args.system};
              networking.hostName = lib.mkDefault k;
            })
            (import ./node.nix parts)
          ];
      })
    )
    (lib.filesystem.importDirToAttrs ./nodes);
}
