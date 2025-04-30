{
  networking.networkmanager.enable = true;
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings.AutoConnect = true;
    };
  };

  # Set the network manager backend to iwd
  networking.networkmanager.wifi.backend = "iwd";

}
