{ ... }:

{
  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
  '';
}
