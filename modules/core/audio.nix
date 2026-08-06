{
  pkgs,
  ...
}:
{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    vlc
    mediainfo
    playerctl
    ffmpegthumbnailer
  ];
}
