{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.timewarrior;
in {
  options.profiles.dermetfan.programs.timewarrior.enable = lib.mkEnableOption "timewarrior" // {
    default = config.programs.timewarrior.enable or false;
  };

  config.home.file = lib.mkIf cfg.enable (
    let
      flexitime = pkgs.fetchFromGitHub {
        owner = "AMNeumann";
        repo = "flexitime";
        rev = "84a1fe568af791af9f11f4df7e4f3d5fa4d0b8b1";
        sha256 = "0nsxz472pd1iw0qxwyis0jhgrsjc7vrx9qwfczdz5vr6hzi9h5j9";
      };
    in {
      ".timewarrior/extensions/totals" = {
        source = "${pkgs.timewarrior}/share/doc/timew/ext/totals.py";
        executable = true;
      };

      ".timewarrior/extensions/flexitime" = {
        source = "${flexitime}/flexitime.py";
        executable = true;
      };

      ".timewarrior/extensions/splittime" = {
        source = "${flexitime}/splittime.py";
        executable = true;
      };
    }
  );
}
