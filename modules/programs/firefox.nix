{ ... }:
{
  # Su Arch era firefox-i18n-it: interfaccia in italiano. Il language
  # pack lo installa programs.firefox, non il pacchetto da solo.
  programs.firefox = {
    enable = true;
    languagePacks = [ "it" ];
  };
}
