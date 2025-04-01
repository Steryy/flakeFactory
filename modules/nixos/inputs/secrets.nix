{
  inputs,
  flakeRoot,
  config,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];
  age.rekey = {
    # hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOy3dC8cCbucumHphroUzZUTKkM0jL3mG3+tkeAWgIdX";
    masterIdentities = [
      {
        identity = "~/.config/sops/age/keys.txt";
        pubkey = "age1wlv6g495tdgsm3vyd28v48j3uydc0se00pa2fzr8w24uelw99fdsu2gr0a";
      }
    ];
    storageMode = "local";
    localStorageDir = flakeRoot + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
