{ writeTextFile }:

writeTextFile {
  name = "vial-udev-rules";
  destination = "/etc/udev/rules.d/92-viia.rules";
  text = ''
    # https://get.vial.today/manual/linux-udev.html
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';
}

