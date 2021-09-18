# Support for swaylock. See https://github.com/swaywm/sway/issues/3631
{
  # security.pam.services.swaylock.text = lib.fileContents "${pkgs.swaylock}/etc/pam.d/swaylock";
  security.pam.services.swaylock = {};
}
