{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.authelia.nginx;
in {
  options.services.authelia.nginx = with lib; {
    enable = mkEnableOption "nginx";

    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule (virtualHostArgs @ { name, ... }: {
        options = {
          host = mkOption {
            type = types.str;
            example = "auth.\${name}.example.com";
          };

          instance = mkOption {
            type = types.str;
            default = virtualHostArgs.name;
          };

          upstream = mkOption {
            type = types.str;
            internal = true;
            readOnly = true;
            default = "http://" + (lib.pipe config.services.authelia.instances.${virtualHostArgs.config.instance}.settings.server.address [
              (lib.removePrefix "tcp://")
              (lib.removePrefix "unix://")
              (v: if lib.hasPrefix ":" v then "127.0.0.1${v}" else v)
            ]);
          };

          protectLocation = mkOption {
            type = with types; functionTo attrs;
            readOnly = true;
            description = "Function that takes a location to protect and returns a submodule to import into `services.nginx.virtualHosts.<name> = _: { imports = <HERE>; };`.";
            default = location: {
              imports = lib.singleton {
                # deduplicate in case this function is used multiple times in a single virtual host submodule
                key = "authelia-${virtualHostArgs.name}-authz-endpoint";

                # https://www.authelia.com/integration/proxies/nginx/#authelia-locationconf
                config.locations."/authelia" = locationArgs: {
                  proxyPass = "${virtualHostArgs.config.upstream}/api/authz/auth-request";

                  extraConfig = ''
                    ## Essential Proxy Configuration
                    internal;

                    ## Headers
                    ## The headers starting with X-* are required.
                    proxy_set_header X-Original-Method $request_method;
                    proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                    proxy_set_header Content-Length "";
                  '' + lib.optionalString (!locationArgs.config.recommendedProxySettings) ''
                    proxy_set_header X-Forwarded-For $remote_addr;
                    proxy_set_header Connection "";
                  '' + ''

                    ## Basic Proxy Configuration
                    proxy_pass_request_body off;
                    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
                    proxy_redirect http:// $scheme://;
                    proxy_http_version 1.1;
                    proxy_cache_bypass $cookie_session;
                    proxy_no_cache $cookie_session;
                    proxy_buffers 4 32k;
                    client_body_buffer_size 128k;

                    ## Advanced Proxy Configuration
                    send_timeout 5m;
                  '' + lib.optionalString (!locationArgs.config.recommendedProxySettings) ''
                    proxy_read_timeout ${config.services.nginx.proxyTimeout};
                    proxy_send_timeout ${config.services.nginx.proxyTimeout};
                    proxy_connect_timeout ${config.services.nginx.proxyTimeout};
                  '';
                };
              };

              # https://www.authelia.com/integration/proxies/nginx/#authelia-authrequestconf
              locations.${location}.extraConfig = ''
                ## Send a subrequest to Authelia to verify if the user is authenticated and has permission to access the resource.
                auth_request /authelia;

                ## Save the upstream response headers from Authelia to variables.
                auth_request_set $user $upstream_http_remote_user;
                auth_request_set $groups $upstream_http_remote_groups;
                auth_request_set $name $upstream_http_remote_name;
                auth_request_set $email $upstream_http_remote_email;

                ## Inject the response headers from the variables into the request made to the backend.
                proxy_set_header Remote-User $user;
                proxy_set_header Remote-Groups $groups;
                proxy_set_header Remote-Name $name;
                proxy_set_header Remote-Email $email;

                ## Configure the redirection when the authz failure occurs. Lines starting with 'Modern Method' and 'Legacy Method'
                ## should be commented / uncommented as pairs. The modern method uses the session cookies configuration's authelia_url
                ## value to determine the redirection URL here. It's much simpler and compatible with the mutli-cookie domain easily.

                ## Modern Method: Set the $redirection_url to the Location header of the response to the Authz endpoint.
                auth_request_set $redirection_url $upstream_http_location;

                ## Modern Method: When there is a 401 response code from the authz endpoint redirect to the $redirection_url.
                error_page 401 =302 $redirection_url;

                # Omitting commented code for legacy method.
              '';
            };
          };
        };
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = lib.mapAttrs' (_: { host, instance, upstream, ... }: lib.nameValuePair host {
      forceSSL = true;

      locations."/" = locationArgs: {
        proxyPass = upstream;

        # https://www.authelia.com/integration/proxies/nginx/#proxyconf
        extraConfig = ''
          ## Headers
          proxy_set_header X-Forwarded-Ssl on;
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
        '' + lib.optionalString (!locationArgs.config.recommendedProxySettings) ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-URI $request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Real-IP $remote_addr;
        '' + ''

          ## Basic Proxy Configuration
          client_body_buffer_size 128k;
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
          proxy_redirect http:// $scheme://;
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 64 256k;
        '' + lib.optionalString (!locationArgs.config.recommendedProxySettings) ''
          proxy_http_version 1.1;
        '' + ''

          ## Trusted Proxies Configuration
          ## Please read the following documentation before configuring this:
          ##     https://www.authelia.com/integration/proxies/nginx/#trusted-proxies
          # set_real_ip_from 10.0.0.0/8;
          # set_real_ip_from 172.16.0.0/12;
          # set_real_ip_from 192.168.0.0/16;
          # set_real_ip_from fc00::/7;
          real_ip_header X-Forwarded-For;
          real_ip_recursive on;

          ## Advanced Proxy Configuration
          send_timeout 5m;
        '' + lib.optionalString (!locationArgs.config.recommendedProxySettings) ''
          proxy_read_timeout ${config.services.nginx.proxyTimeout};
          proxy_send_timeout ${config.services.nginx.proxyTimeout};
          proxy_connect_timeout ${config.services.nginx.proxyTimeout};
        '';
      };
    }) cfg.virtualHosts;
  };
}
