{inputs, ...}: let
in {
  imports = [
    inputs.easy-hosts.flakeModule
  ];
}
