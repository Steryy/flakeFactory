{ config, lib, pkgs, ... }: {
  # Enable the threadirqs kernel parameter to reduce pipewire/audio latency
  boot = lib.mkIf config.services.pipewire.enable {
    # - Inpired by: https://github.com/musnix/musnix/blob/master/modules/base.nix#L56
    kernelParams = [ "threadirqs" ];
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    playerctl
    pulseaudio
    pulsemixer
    pwvucontrol
  ];

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      # Enable 32-bit support
      alsa.support32Bit = lib.mkForce config.hardware.graphics.enable32Bit;
      jack.enable = false;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        extraConfig.bluetoothEnhancements = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            # "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
          };
        };
      };
    };
  };

  # Allow members of the "audio" group to set RT priorities
  security = { rtkit.enable = true; };

}
