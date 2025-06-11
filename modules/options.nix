{lib, ...}: {
  options.clan.inventory = {
    machines = lib.mkOption {
      type = lib.types.attrs;
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };
}
