{ inputs, ... }:

{ options, config, lib, utils, pkgs, ... }:

let
  cfg = config.defaults;
in {
  options.defaults.enable = lib.mkEnableOption "sensible defaults";

  config = lib.mkIf cfg.enable {
    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;

      nixPath = map (entry:
        if lib.hasPrefix "nixpkgs=" entry
        then "nixpkgs=${inputs.nixpkgs}"
        else entry
      ) options.nix.nixPath.default;

      settings = {
        trusted-public-keys = [
          "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        ];

        trusted-users = [
          "root"
          "@${config.users.groups.wheel.name}"
        ];

        connect-timeout = 5;

        min-free = 1024 * 1024 * 512; # 512 MiB
        max-free = 1024 * 1024 * 1024 * 2; # 2 GiB

        auto-optimise-store = true;
      };
    };

    environment = {
      # lxqt-config-brightness refuses to work if `$SHELL` is not in `/etc/shells`.
      shells = map utils.toShellPath (
        [ config.users.defaultUserShell ] ++
        map (user: user.shell) (builtins.attrValues config.users.users)
      );

      # for nix' own shell completions
      pathsToLink = [
        "/share/bash-completion"
        "/share/zsh"
        "/share/fish"
      ];
    };

    networking = {
      useDHCP = lib.mkDefault false;

      hostId = lib.mkDefault (builtins.substring 0 8 (
        builtins.hashString "md5" config.networking.hostName
      ));

      firewall.allowedTCPPorts = lib.optionals config.services.nginx.enable (
        let
          any = cond: lib.any cond (
            builtins.attrValues config.services.nginx.virtualHosts
          );
          # Conditions copied from the nginx module.
          # Unfortunately it does not expose its resolved listen addresses.
          onlySSL = h: h.onlySSL || h.enableSSL;
          hasSSL = h: onlySSL h || h.addSSL || h.forceSSL;
          # Run `systemctl restart acme-fixperms.service` if permissions in /var/lib/acme cause troubles.
        in
          lib.optional (any (h: !(onlySSL h))) config.services.nginx.defaultHTTPListenPort ++
          lib.optional (any (h: hasSSL h || (
            if lib.versionAtLeast lib.version "21.11"
            then h.rejectSSL
            else false
          ))) config.services.nginx.defaultSSLListenPort
      );
    };

    security.acme.acceptTerms = true;

    services = {
      pipewire.alsa.support32Bit = pkgs.stdenv.isx86_64;

      pulseaudio = {
        support32Bit = pkgs.stdenv.isx86_64;
        extraConfig = ''
          load-module module-echo-cancel source_name=noecho
          set-default-source noecho
        '';
      };

      syncthing.openDefaultPorts = true;

      xserver.synaptics.palmDetect = true;

      minecraft-server = {
        eula = true;
        openFirewall = true;
      };

      nginx = {
        recommendedOptimisation   = true;
        recommendedProxySettings  = true;
        recommendedTlsSettings    = true;
        recommendedGzipSettings   = true;
        recommendedBrotliSettings = true;
        recommendedZstdSettings   = true;
      };
    };

    programs = {
      # breaks impure nix-shell before Nix 1.11.5
      # https://github.com/NixOS/nix/issues/976
      # https://github.com/NixOS/nixpkgs/issues/14172
      bash.completion.enable = lib.mkIf (
        lib.versionAtLeast builtins.nixVersion "1.11.5"
      ) false;

      zsh.shellAliases = {
        l = "ls -lah";
        ll = "ls -lh";
      };

      nano.nanorc = ''
        set tabsize 4
        set autoindent
        set smarthome
      '';
    };

    console.useXkbConfig = true;

    hardware = {
      graphics.enable32Bit = pkgs.stdenv.isx86_64;

      # https://nixos.wiki/wiki/Bluetooth#Enabling_A2DP_Sink
      bluetooth.settings.General.Enable = lib.concatStringsSep "," ["Source" "Sink" "Media" "Socket"];
    };

    boot.loader.timeout = lib.mkDefault 1;
  };
}
