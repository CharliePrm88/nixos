{
  pkgs,
  ...
}:
{
  # Un solo JDK, dichiarato in un posto solo. Prima ce n'erano due in
  # environment.systemPackages (openjdk21 e openjdk25): due `java` nel
  # PATH globale, con l'ordine deciso dall'ordine della lista.
  #
  # programs.java imposta anche JAVA_HOME a livello di sistema, quindi
  # non serve piu' l'export scritto a mano in ~/.zshrc.local (che
  # comunque puntava a /usr/lib/jvm, percorso FHS inesistente su NixOS).
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };
}
