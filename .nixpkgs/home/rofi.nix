{
  target = ".config/rofi/config";
  text = ''
    rofi.bw: 0
    rofi.separator-style: none
    rofi.scrollbar-width: 5
    rofi.width: 25
    rofi.opacity: 25
    rofi.fake-transparency: true
    rofi.fake-background: screenshot
    rofi.terminal: lilyterm
    ! rofi.ssh-client: mosh
  '';
}
