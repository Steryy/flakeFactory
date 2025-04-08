{
  pkgs,
  config,
  ...
}: let
  agentTimeout = 60 * 60 * 39;
in {
  services.gpgUnloc = {
    envfile =
      config.age.secrets."gpg.env".path;
    enable = true;
  };
  age.secrets = {
    "gpg.env" = {};
  };
  home.packages = [
    pkgs.gnupg
  ];
  services = {
    gpg-agent = {
      enable = true;
      # sshKeys = authkeys;
      enableExtraSocket = true;
      enableScDaemon = true;

      # pinentryPackage = cfg.pinentry;

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
