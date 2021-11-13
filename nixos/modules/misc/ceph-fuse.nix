{ config, lib, pkgs, ... }:

let
  cfg = config.services.ceph.osd.activate;
in {
  config = lib.mkIf (lib.any (fs: fs == "fuse.ceph-fixed") config.boot.supportedFilesystems) {
    system.fsPackages = [
      # TODO fix original wrapper in nixpkgs
      # see also https://github.com/NixOS/nixpkgs/issues/21748#issuecomment-271147560
      (with pkgs; runCommand "wrap-mount.fuse.ceph" {
        buildInputs = [ makeWrapper ];
      } ''
        wrapped=$out/bin/mount.fuse.ceph
        mkdir -p $(dirname $wrapped)
        # TODO use sbin path from ceph-client package on update to >21.05
        cp ${ceph}/bin/mount.fuse.ceph $wrapped
        wrapProgram $wrapped --suffix PATH : ${util-linux}/bin
        mv $wrapped $wrapped-fixed
      '')
    ];
  };
}
