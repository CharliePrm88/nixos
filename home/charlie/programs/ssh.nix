{ ... }:
{
  # Sostituisce il blocco ssh-agent scritto a mano in ~/.zshrc.local, che
  # esportava SSH_AUTH_SOCK e faceva `ssh-add` a ogni apertura di shell.
  # L'unita' utente esporta SSH_AUTH_SOCK da sola e vive quanto la
  # sessione, non quanto il terminale.
  #
  # Le chiavi non vengono caricate automaticamente: si aggiungono con
  # `ssh-add ~/.ssh/<chiave>`, oppure una volta sola mettendo
  # `AddKeysToAgent yes` in ~/.ssh/config.
  #
  # NB: programs.ssh di Home Manager NON e' abilitato di proposito:
  # prenderebbe in gestione ~/.ssh/config, che qui e' scritto a mano.
  services.ssh-agent.enable = true;
}
