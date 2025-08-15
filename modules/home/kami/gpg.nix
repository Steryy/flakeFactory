{ pkgs, config, ... }:
let agentTimeout = 60 * 60 * 39;
in {
  services.gpgUnlock = {
    envfile = config.sops.secrets."gpg.env".path;
    enable = true;
  };
  systemd.user.services.gpgunlock.Unit.After = [ "sops-nix.service" ];
  home.packages = [ pkgs.gnupg ];

  sops.secrets = { "gpg.env" = { }; };
  services = {
    gpg-agent = {
      enable = true;
      # sshKeys = authkeys;
      enableExtraSocket = true;
      enableScDaemon = true;

      pinentry.package = with pkgs; pinentry-qt ;

      defaultCacheTtl = agentTimeout;
      maxCacheTtl = agentTimeout;
      defaultCacheTtlSsh = agentTimeout;
      maxCacheTtlSsh = agentTimeout;
      enableSshSupport = true;
      extraConfig = ''
        allow-preset-passphrase
      '';
    };
  };
}
