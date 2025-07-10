_:

{ config, lib, ... }:

let
  cfg = config.profiles.notebook;
in {
  options.profiles.notebook.enable = lib.mkEnableOption "notebook settings";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    programs.light = {
      enable = true;
      brightnessKeys = {
        enable = true;
        step = 5;
      };
    };

    services.tlp = {
      enable = true;
      settings = {
        # https://linrunner.de/tlp/support/optimizing.html#extend-battery-runtime
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        AMDGPU_ABM_LEVEL_ON_BAT = 3;

        # https://linrunner.de/tlp/support/optimizing.html#improve-performance-on-ac-power
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        PLATFORM_PROFILE_ON_AC = "performance";

        # https://linrunner.de/tlp/settings/processor.html#cpu-scaling-governor-on-ac-bat
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # https://linrunner.de/tlp/settings/rdw.html#devices-to-disable-on-connect
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";

        # https://linrunner.de/tlp/settings/rdw.html#devices-to-enable-on-disconnect
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";
      };
    };
  };
}
