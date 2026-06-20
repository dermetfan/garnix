{
  home.file.".cargo/config".text = ''
    [cargo-new]
    name = "Robin Stumm"
    email = "serverkorken@gmail.com"
    vcs = "git"
  '';

  programs = {
    bash.initExtra = ''
      PATH="$PATH":~/.cargo/bin
    '';
    zsh.initExtra = ''
      path+=(~/.cargo/bin)
    '';
    fish.shellInit = ''
      fish_add_path ~/.cargo/bin
    '';
  };
}
