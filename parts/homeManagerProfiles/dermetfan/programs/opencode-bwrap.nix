{ self, config, lib, pkgs, ... }:

{
  imports = [
    self.inputs.opencode-bwrap.homeManagerModules.default
  ];

  programs.opencode-bwrap = {
    dataDirPrefix = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome + "/opencode-bwrap";
    extraPackages = with pkgs; [
      python3
      mcp-nixos
    ];
    extraConfig.mcp.nixos = {
      enabled = true;
      type = "local";
      command = ["mcp-nixos"];
    };
  };
}
