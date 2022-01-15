{ config, lib, pkgs, ... }:

let
  cfg = config.boot.kernelNetwork;

  netmask = builtins.readFile (let
    pkgs2111 = lib.traceIf (lib.versionAtLeast pkgs.ipcalc.version "1.0.1") ''
      Your nixpkgs has a recent enough ipcalc.
      You can remove the separate dependency on nixpkgs 21.11 in kernel-network.nix.
    '' (builtins.getFlake "github:NixOS/nixpkgs/69f169c5f08e7a5827aaafad342a5eddfc805e16").legacyPackages.${pkgs.system};
  in
    with cfg.ipv4;
    pkgs.runCommandNoCCLocal "netmask" {} ''
      ${pkgs2111.ipcalc}/bin/ipcalc -m ${address}/${toString prefixLength} \
      | cut -d = -f 2 \
      | tr -d \\n \
      > $out
    ''
  );
in {
  options.boot.kernelNetwork = with lib; {
    enable = mkEnableOption "static IPv4 configuration in the initial ramdisk";
    ipv4 = {
      address = mkOption {
        type = types.str;
        example = "(builtins.elemAt config.networking.interfaces.eth0.ipv4.addresses 0).address";
      };
      prefixLength = mkOption {
        type = types.int;
        example = "(builtins.elemAt config.networking.interfaces.eth0.ipv4.addresses 0).prefixLength";
      };
    };
  };

  config.boot.kernelParams = lib.optionals cfg.enable [
    "ip=${cfg.ipv4.address}::${config.networking.defaultGateway.address}:${netmask}:${config.networking.hostName}::off"
  ];
}
