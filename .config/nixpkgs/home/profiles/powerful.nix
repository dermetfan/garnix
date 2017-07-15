{ config, pkgs, ... }:

{
  xsession.initExtra =
    let
      compton = "${pkgs.compton}/bin/compton";
    in ''
      ${compton} -bfD 2
    '';
}
