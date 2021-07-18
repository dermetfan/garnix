[
  profiles/desktop.nix
  profiles/media.nix
  profiles/dev.nix
  profiles/admin.nix
  profiles/office.nix
  profiles/game.nix
  profiles/gui.nix

  misc/nixos.nix
  misc/gtk.nix
  misc/pulseaudio-oneshot.nix
  misc/norman.nix
  misc/uhk.nix

  services/picom.nix
  services/dunst.nix
  services/i3-sway/i3.nix
  services/i3-sway/sway.nix
  services/parcellite.nix
  services/xscreensaver.nix
  services/rsibreak.nix

  programs/alacritty.nix
  programs/antigen.nix
  programs/bat.nix
  programs/cargo.nix
  programs/elvish.nix
  programs/firefox.nix
  programs/geany.nix
  programs/git.nix
  programs/htop.nix
  programs/i3status.nix
  programs/i3status-rust.nix
  programs/kakoune.nix
  programs/lilyterm.nix
  programs/mercurial.nix
  programs/micro.nix
  programs/minecraft.nix
  programs/nano.nix
  programs/networkmanager-dmenu.nix
  programs/nitrogen.nix
  programs/ranger.nix
  programs/rofi.nix
  programs/st.nix
  programs/starship.nix
  programs/swappy.nix
  programs/swaylock.nix
  programs/timewarrior.nix
  programs/tmux.nix
  programs/volumeicon.nix
  programs/xfe.nix
  programs/xpdf.nix
  programs/zsh.nix
] ++ (if builtins.pathExists profiles/local.nix then [
  profiles/local.nix
] else [])
