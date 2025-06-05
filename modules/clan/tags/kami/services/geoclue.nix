{lib,pkgs , options, config, ...}:{

    time.timeZone = lib.mkForce null;
    services.automatic-timezoned.enable = true;
    services.geoclue2.enableDemoAgent = lib.mkForce true;
    services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";

    systemd.services = 
    
    (lib.optionalAttrs (options ? "persistence") {

    restore-timezone =
        let
          file = "${config.persistence.cache.directory}/etc/localtime";
        in
       {
        description = "Restore /etc/localtime from /persist";
        wantedBy = [ "multi-user.target" ];
        unitConfig.RequiresMountsFor = "/persist";
        serviceConfig.Type = "oneshot";
        # We want to run `ExecStop` when the computer is shutting down
        serviceConfig.RemainAfterExit = true;
        serviceConfig.ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "restore-timezone";
          text = ''
            if [[ -L ${file} ]]; then
              cp -av  ${file} /etc/localtime
            fi
          '';
        });
        serviceConfig.ExecStop = lib.getExe (pkgs.writeShellApplication {
          name = "persist-timezone";
          text = ''
            mkdir -p ${config.persistence.cache.directory}/etc
            cp -av /etc/localtime ${file}
          '';
        });
      };
    });
}
