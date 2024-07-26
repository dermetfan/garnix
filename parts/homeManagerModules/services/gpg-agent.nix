{ lib, pkgs, ... }:

{
    # TODO remove once fixed upstream
    # https://github.com/nix-community/home-manager/issues/5146#issuecomment-2156125022
    services.gpg-agent.pinentryPackage = lib.mkDefault pkgs.pinentry;
}
