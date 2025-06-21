{
  lib,
  pkgs,
  ...
}: {
  boot = {
    tmp.useTmpfs = true;
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
