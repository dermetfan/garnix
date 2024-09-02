{ self, config, lib, pkgs, ... }:

let
  cfg = config.programs.atuin;
in {
  programs.atuin = {
    package = self.inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.atuin;

    settings = {
      update_check = false;
      sync.records = true;
      dotfiles.enabled = false;
      daemon = {
        enabled = true;
        systemd_socket = true;
      };
    };
  };

  systemd.user = lib.mkIf (cfg.enable && cfg.settings.daemon.enabled) {
    services.atuind.Service = {
      ExecStart = "${lib.getExe cfg.package} daemon";
      Environment = [ "ATUIN_LOG=info" ];
    };

    sockets.atuind = lib.mkIf cfg.settings.daemon.systemd_socket {
      Unit.Description = "atuin daemon socket";
      Socket.ListenStream = "%h/.local/share/atuin/atuin.sock";
      Install.WantedBy = [ "sockets.target" ];
    };
  };
}
