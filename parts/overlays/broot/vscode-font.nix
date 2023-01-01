{ lib, fetchurl, broot }:

fetchurl {
  name = "broot-vscode-font-${broot.version}";
  url = "https://github.com/Canop/broot/raw/v${broot.version}/resources/icons/vscode/vscode.ttf";

  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    install -D $downloadedFile $out/share/fonts/truetype/vscode.ttf
  '';

  hash = (
    {
      "1.11.1" = "sha256-2CZtR5WYak4Cv1mRj+Ol0iT6Q+Cuvz54EBcLi2AiiVE=";
    } // lib.genAttrs [ "1.12.0" "1.16.2" ] (_: "sha256-zj9izSPj2p3k1fNysFMdEcEaHWwD241TBrY9RLKBU4c=")
  ).${broot.version};

  meta = with lib; {
    description = "VSCode Font from Broot";
    homepage = "https://dystroy.org/broot/icons/#setting-up-the-font";
    maintainers = with maintainers; [ dermetfan ];
    platforms = platforms.all;
  };
}

