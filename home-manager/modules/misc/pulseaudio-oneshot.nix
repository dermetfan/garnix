{ config, lib, pkgs, ... }:

let
  cfg = config.programs.pulseaudio-oneshot;
in {
  options.programs.pulseaudio-oneshot.enable = lib.mkEnableOption "pulseaudio-oneshot";

  config.home.packages = lib.optional cfg.enable (
    pkgs.writers.writeDashBin "pulseaudio-oneshot" ''
      config=$(${pkgs.mktemp}/bin/mktemp)
      trap "rm $config" EXIT

      cat ${pkgs.pulseaudio}/etc/pulse/default.pa - > $config <<EOF
      load-module module-echo-cancel source_name=noecho
      set-default-source noecho
      EOF

      ${pkgs.pulseaudio}/bin/pulseaudio -nDF $config --use-pid-file
      trap "kill $(< /run/user/$UID/pulse/pid)" EXIT

      ${pkgs.pavucontrol}/bin/pavucontrol
    ''
  );
}
