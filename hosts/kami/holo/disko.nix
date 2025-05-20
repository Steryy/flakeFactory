{  flakeRoot, config, ... }:
let
  pers = "persist";
  root = "root";
in {
  imports = [
    (flakeRoot + "/modules/disko/btrfs-luks.nix") 
    (flakeRoot + "/modules/disko/password.nix") 
  ];
  diskoTemplate = {
    disk = {
      labels = [ "bootL" "looksLabelRoot" "luksMapped" ];
      inherit root;
      device = "/dev/disk/by-id/nvme-SKHynix_HFS001TEJ9X115N_AYCBN03291050BS23";
      keyFiles = [
        # "/tmp/keyfile"
        "/dev/disk/by-id/usb-TOSHIBA_TransMemory_C412F52D6C8CC011300B68D7-0:0-part2"
      ];
      fsType = "btrfs";
      passFile = config.clan.core.vars.generators.diskpassword.files.diskpassword.path;
      keyFileSize = 4096;
      additionalMount = {
        "@swap" = {
          mountpoint = "/.swapvol";
          swap.swapping.size = "16G";
        };

        # "@snapshots" = {
        #   mountpoint = "/persist/@system/.snapshots";
        #   mountOptions = [
        #     "compress=zstd"
        #     "noatime"
        #   ];
        # };
        "@${pers}" = {
          mountpoint = "/${pers}";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
      };
    };
  };
}
