{
  allowUnfree = true;

  firefox.enableAdobeFlash = true;

  chromium = {
    enablePepperFlash = true;
    enablePepperPDF = true;
  };

  packageOverrides = pkgs: {
    home-manager = import ./home-manager { inherit pkgs; };
  };
}
