{ config, lib, pkgs, ... }:

let
  cfg = config.boot.kernelNetwork;

  netmask = builtins.readFile (
    with cfg.ipv4;
    pkgs.runCommandNoCCLocal "netmask" {} ''
      ${pkgs.ipcalc}/bin/ipcalc -m ${address}/${toString prefixLength} \
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
