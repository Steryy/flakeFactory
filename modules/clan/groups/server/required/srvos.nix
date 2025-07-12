{inputs, ...}: {
  imports = with inputs.srvos.nixosModules; [
    server
    mixins-telegraf
    mixins-terminfo
  ];
}
