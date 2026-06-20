_:

{ config, lib, ... }:

let
  cfg = config.profiles.notebook;
in {
  options.profiles.notebook.enable = lib.mkEnableOption "notebook settings";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    misc.hotkeys.brightness = {
      enable = true;
      step = "2%";
    };

    services.tlp = {
      enable = lib.mkDefault true;
      settings = {
        TLP_AUTO_SWITCH = 1;

        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_SAV = "powersave";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_BOOST_ON_SAV = 0;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_SAV = 0;

        AMDGPU_ABM_LEVEL_ON_SAV = 4;

        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth";
      } // (if lib.versionAtLeast config.services.tlp.package.version "1.10" then lib.trace "You can delete support for TLP < v1.10 from ${./notebook.nix}" {
        TLP_PROFILE_DEFAULT = "BAL";
        TLP_PROFILE_BAT = "SAV";
      } else {
        TLP_DEFAULT_MODE = "SAV";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        AMDGPU_ABM_LEVEL_ON_BAT = 4;
      });
    };
  };
}
