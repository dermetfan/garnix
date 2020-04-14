[
  profiles/nixos.nix
  profiles/desktop.nix
  profiles/effects.nix
  profiles/media.nix
  profiles/dev.nix
  profiles/admin.nix
  profiles/office.nix
  profiles/game.nix

  misc/gtk.nix
  misc/pulseaudio-oneshot.nix

  services/compton.nix
  services/dunst.nix
  services/i3.nix
  services/parcellite.nix
  services/xscreensaver.nix
  services/rsibreak.nix

  programs/alacritty.nix
  programs/antigen.nix
  programs/cargo.nix
  programs/elvish.nix
  programs/firefox.nix
  programs/geany.nix
  programs/git.nix
  programs/htop.nix
  programs/i3status.nix
  programs/i3status-rust.nix
  programs/lilyterm.nix
  programs/mercurial.nix
  programs/micro.nix
  programs/minecraft.nix
  programs/nano.nix
  programs/nitrogen.nix
  programs/ranger.nix
  programs/rofi.nix
  programs/st.nix
  programs/starship.nix
  programs/timewarrior.nix
  programs/tmux.nix
  programs/volumeicon.nix
  programs/xfe.nix
  programs/xpdf.nix
  programs/zsh.nix
] ++ (if builtins.pathExists profiles/local.nix then [
  profiles/local.nix
] else [])
