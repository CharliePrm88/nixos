{
  pkgs,
  ...
}:
let
  nixup = pkgs.writeShellApplication {
    name = "nixup";
    # nix, nixos-rebuild, nixos-version e sudo restano quelli di sistema
    # (dal PATH): un pkgs.sudo qui non sarebbe il wrapper setuid di
    # /run/wrappers e un pkgs.nix potrebbe non coincidere col demone.
    runtimeInputs = with pkgs; [
      coreutils # mktemp
      diffutils # cmp
      hostname
      jq
      nvd
    ];
    text = builtins.readFile ./nixup.sh;
  };
in
{
  home.packages = [ nixup ];
}
