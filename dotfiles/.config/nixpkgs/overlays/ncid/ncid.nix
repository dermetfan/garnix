{ stdenv, fetchurl
, tcl, tk, ... }:

stdenv.mkDerivation rec {
  name = "ncid-${version}";
  version = "1.6";

  src = fetchurl {
    url = "mirror://sourceforge/project/ncid/ncid/${version}/ncid-${version}-src.tar.gz";
    sha256 = "1x0466hi6a88324pzpppzvamfbvv8ja1jr2b3qpxh5mf5hjif6cy";
  };
  sourceRoot = "ncid/client";

  postConfigure = ''
    cat <<EOF | sed -i -f- Makefile */Makefile
    s,^prefix[ tab]*=[ tab]*/usr/local$,prefix = $out,
    s,^TCLSH[ tab]*=[ tab]*tclsh$,TCLSH = ${tcl}/bin/tclsh,
    s,^WISH[ tab]*=[ tab]*wish$,WISH = ${tk}/bin/wish,
    EOF
  '';

  propagatedBuildInputs = [ tcl tk ];
  buildFlags = [ "local" ];

  meta.homepage = http://ncid.sourceforge.net;
}
