self:

final: prev: {
  vial-udev-rules = prev.callPackage ./vial-udev-rules.nix {};
}
