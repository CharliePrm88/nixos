{
  pkgs,
  ...
}:
{
  # Su Arch c'erano tre JDK in /usr/lib/jvm (8, 21, 25, con sorgenti e
  # javadoc). Quello di default (25) arriva da programs.java
  # (modules/programs/java.nix) ed e' l'unico nel PATH; gli altri sono
  # esposti qui in ~/.jdks, la cartella che IntelliJ, Android Studio e
  # gli altri IDE JetBrains scansionano da soli. Cosi' i progetti che
  # chiedono Java 8 o 21 trovano l'SDK senza toccare il PATH.
  home.file = {
    ".jdks/openjdk-8".source = "${pkgs.jdk8}/lib/openjdk";
    ".jdks/openjdk-21".source = "${pkgs.jdk21}/lib/openjdk";
    ".jdks/openjdk-25".source = "${pkgs.jdk25}/lib/openjdk";
  };
}
