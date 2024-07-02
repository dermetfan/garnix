{ lib, runCommandNoCC, broot }:

runCommandNoCC "broot-vscode-font-${broot.version}" {
  meta = with lib; {
    description = "VSCode Font from Broot";
    homepage = "https://dystroy.org/broot/icons/#setting-up-the-font";
    maintainers = with maintainers; [ dermetfan ];
    platforms = platforms.all;
  };
} ''
  dir="$out"/share/fonts/truetype
  mkdir --parents "$dir"
  ln --symbolic ${broot.src + /resources/icons/vscode/vscode.ttf} "$dir"/
''
