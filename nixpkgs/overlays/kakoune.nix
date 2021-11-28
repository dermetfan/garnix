final: prev: {
  kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs (oldAttrs: {
    postInstall = ''
      ${oldAttrs.postInstall}
      ln -s ${prev.fetchFromGitHub {
        owner = "Anfid";
        repo = "cosy-gruvbox.kak";
        rev = "9acb0c6c3166147570a94e722cad2da75a6a9421";
        hash = "sha256-3koUXhgGT33l+yqMHHxL4PlJwOGTLjS10Egv+XjUDDU=";
      }}/colors/cosy-gruvbox.kak $out/share/kak/colors/
    '';
  });
}
