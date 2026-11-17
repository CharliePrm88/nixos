{ ... }:
{
  # Client di posta, usato soprattutto per aprire i .eml (message/rfc822)
  # e i link mailto: (associazioni in home/charlie/desktop/mime.nix).
  # Come per Firefox, il language pack italiano lo installa il modulo,
  # non il pacchetto da solo.
  programs.thunderbird = {
    enable = true;
    languagePacks = [ "it" ];
  };
}
