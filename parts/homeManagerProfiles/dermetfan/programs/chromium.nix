{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.chromium;
in {
  options.profiles.dermetfan.programs.chromium.enable = lib.mkEnableOption "chromium" // {
    default = config.programs.chromium.enable;
  };

  config = {
    programs.chromium = {
      dictionaries = with pkgs.hunspellDictsChromium; [
        de_DE
      ];

      nativeMessagingHosts = with pkgs; [
        gopass-jsonapi
      ];

      extensions = [
        { id = "ilgbgfnhidfdnfnimfohnfdhdbejpoap"; } # auto-reject-cookies
        { id = "kkhfnlkhiapbiehimabddjbimfaijdhk"; } # gopass-bridge
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # darkreader
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # decentraleyes
        { id = "jeoacafpbcihiomhlakheieifhpjdfeo"; } # disconnect
        { id = "jfcmbgcnangoalgpopaakignejjfpcmo"; } # export-tabs-urls-and-titles
        { id = "hdhinadidafjejdhmfkjgnolgimiaplp"; } # read-aloud
        { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock-origin-lite
        { id = "khncfooichmfjbepaaaebmommgaepoid"; } # youtube-recommended-videos
      ];
    };
  };
}

