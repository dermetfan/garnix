{ pkgs }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    steamcontroller-udev-rules = pkgs.writeTextFile {
      name = "steamcontroller-udev-rules";
      destination = "/etc/udev/rules.d/99-steamcontroller.rules";
      text = ''
        # This rule is needed for basic functionality of the controller in
        # Steam and keyboard/mouse emulation
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
        # This rule is necessary for gamepad emulation; make sure you
        # replace 'pgriffais' with the username of the user that runs Steam
        KERNEL=="uinput", MODE="0660", GROUP="wheel", OPTIONS+="static_node=uinput"
        # systemd option not yet tested
        #KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", TAG+="udev-acl"
        # HTC Vive HID Sensor naming and permissioning
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", MODE="0666"
      '';
    };
  };

  services.udev.packages = [ pkgs.steamcontroller-udev-rules ];
}
