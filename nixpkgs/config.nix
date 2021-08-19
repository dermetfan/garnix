{
  allowUnfree = true;

  android_sdk.accept_license = true;

  packageOverrides = pkgs: {
    nur = import <nur> { inherit pkgs; };
  };
}
