{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      uhk-udev-rules = pkgs.writeTextFile {
        name = "uhk-udev-rules";
        destination = "/etc/udev/rules.d/50-uhk60.rules";
        text = ''
          # Ultimate Hacking Keyboard rules
          # These are the udev rules for accessing the USB interfaces of the UHK as non-root users.
          # Copy this file to /etc/udev/rules.d and physically reconnect the UHK afterwards.
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0666"
        '';
      };
    })
  ];

  services.udev.packages = [ pkgs.uhk-udev-rules ];
}
