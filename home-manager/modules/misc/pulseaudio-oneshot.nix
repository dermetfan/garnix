{ config, lib, ... }:

let
  cfg = config.misc.pulseaudio-oneshot;
in {
  options.misc.pulseaudio-oneshot.enable = lib.mkEnableOption "pulseaudio-oneshot";

  config.home.file."bin/pulseaudio-oneshot" = lib.mkIf cfg.enable {
    executable = true;
    text = ''
      #! /usr/bin/env nix-shell
      #! nix-shell -i bash -p bash pulseaudio mktemp pavucontrol

      pulseaudio=$(dirname $(realpath `which pulseaudio`))/..

      config=`mktemp`
      trap "rm $config" EXIT

      cat $pulseaudio/etc/pulse/default.pa - > $config <<EOF
      load-module module-echo-cancel source_name=noecho
      set-default-source noecho
      EOF

      pulseaudio -nDF $config --use-pid-file
      trap "kill `cat /run/user/$UID/pulse/pid`" EXIT

      pavucontrol
    '';
  };
}
