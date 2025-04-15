{lib, ...}: {
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  services.gnome.evolution-data-server.enable = false;
  services.gnome.gnome-online-accounts.enable = false;
}
