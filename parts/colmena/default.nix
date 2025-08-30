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

      defaults = { name, config, lib, pkgs, ... }: {
        imports = [
          parts.config.flake.nixosModules.default
          (import ./node.nix {
            inherit moduleWithSystem;
            inherit (parts) config;
          })
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

        /*
        On ZFS 2.3.3 (default in NixOS 25.05), `ls -lA …/.zfs/snapshot/…` sometimes hung forever, unkillable.

        I found this in dmesg:

        ```
        [2840100.162707] VERIFY(avl_find(tree, new_node, &where) == NULL) failed
        [2840100.162717] PANIC at avl.c:625:avl_add()
        [2840100.162721] Showing stack for process 3105047
        [2840100.162725] CPU: 1 UID: 1000 PID: 3105047 Comm: fish Tainted: P           O       6.12.35 #1-NixOS
        [2840100.162729] Tainted: [P]=PROPRIETARY_MODULE, [O]=OOT_MODULE
        [2840100.162730] Hardware name: System manufacturer System Product Name/P8H77-M PRO, BIOS 9012 09/18/2018
        [2840100.162732] Call Trace:
        [2840100.162735]  <TASK>
        [2840100.162739]  dump_stack_lvl+0x5d/0x90
        [2840100.162749]  spl_panic+0xf4/0x10b [spl]
        [2840100.162770]  ? __kmalloc_noprof+0x1ba/0x440
        [2840100.162775]  avl_add+0x98/0xa0 [zfs]
        [2840100.163003]  zfsctl_snapshot_mount+0x86e/0x9c0 [zfs]
        [2840100.163184]  zpl_snapdir_automount+0x10/0x20 [zfs]
        [2840100.163358]  __traverse_mounts+0x8f/0x210
        [2840100.163365]  step_into+0x350/0x790
        [2840100.163368]  ? __pfx_zpl_snapdir_revalidate+0x10/0x10 [zfs]
        [2840100.163543]  link_path_walk.part.0.constprop.0+0x22e/0x3a0
        [2840100.163547]  path_openat+0x9b/0x12f0
        [2840100.163550]  ? cp_statx+0x1bb/0x200
        [2840100.163556]  do_filp_open+0xc4/0x170
        [2840100.163561]  do_sys_openat2+0xb4/0xe0
        [2840100.163565]  __x64_sys_openat+0x55/0xb0
        [2840100.163567]  do_syscall_64+0xb7/0x210
        [2840100.163572]  entry_SYSCALL_64_after_hwframe+0x77/0x7f
        [2840100.163576] RIP: 0033:0x7f02de2caf40
        [2840100.163591] Code: 4c 89 54 24 18 41 89 f2 41 83 e2 40 75 4c 89 f0 f7 d0 a9 00 00 41 00 74 41 89 f2 b8 01 01 00 00 48 89 fe bf 9c ff ff ff 0f 05 <48> 3d 00 f0 ff ff 77 50 48 8b 54 24 18 64 48 2b 14 25 28 00 00 00
        [2840100.163593] RSP: 002b:00007f02ddec47e0 EFLAGS: 00000206 ORIG_RAX: 0000000000000101
        [2840100.163597] RAX: ffffffffffffffda RBX: 00007f02ddec4950 RCX: 00007f02de2caf40
        [2840100.163599] RDX: 0000000000090800 RSI: 00007f02d00267d0 RDI: 00000000ffffff9c
        [2840100.163601] RBP: 0000000000000000 R08: 00007f02d0026840 R09: 00fffcfffef0fffe
        [2840100.163602] R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000080
        [2840100.163604] R13: 0000000000000000 R14: 0000000000000004 R15: 00007f02d00267d0
        [2840100.163607]  </TASK>
        ```

        Some had similar issues and said that downgrading to 2.3.1 or 2.2.7 avoids it.
        According to the feature matrix, my pool is compatible with 2.2.8:
        https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Feature%20Flags.html
        I never encountered this issue on NixOS 24.11 (which defaults to ZFS 2.2.6).

        - https://github.com/openzfs/zfs/issues/17493
        - https://github.com/openzfs/zfs/issues/17307
        - https://github.com/openzfs/zfs/issues/16685#issuecomment-2979428722
        - https://github.com/openzfs/zfs/issues/17659
        - https://forum.proxmox.com/threads/kernel-panic-after-update-to-proxmox-9.169652/
        - https://github.com/openzfs/zfs/issues/9461#issuecomment-2640606187
        */
        boot.zfs.package = lib.mkDefault pkgs.zfs_2_2;
      };
    }
  );
}
