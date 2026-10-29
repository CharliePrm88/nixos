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
    # Codec GStreamer (gst-plugins-good/bad su Arch): li usano i lettori
    # e le anteprime di MATE.
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];
}
