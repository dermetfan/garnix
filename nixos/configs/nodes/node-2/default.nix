self: rec {
  system = "x86_64-linux";

  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    { nixpkgs.pkgs = nixpkgs.legacyPackages.${system}.extend self.outputs.overlay; }
  ];

  nixpkgs = self.inputs."nixpkgs-21.05";
}
