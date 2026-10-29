{
  config,
  ...
}:
let
  # Identita' di default: quella personale. Va bene per questa repo,
  # per i progetti su GitHub e per qualunque cosa non sia lavoro.
  identitaPersonale = {
    name = "Stefano Ponzi";
    email = "CharliePrm88@users.noreply.github.com";
  };

  # L'identita' aziendale NON sta nella repo: e' un dato che non deve
  # rientrare nella storia di git (vedi .gitleaks.toml e .githooks/).
  # Vive in un file locale, da creare a mano una volta sola:
  #
  #     [user]
  #         name = Stefano Ponzi
  #         email = nome.cognome@azienda.example
  #
  # Se il file non esiste git lo ignora in silenzio e resta valida
  # l'identita' personale. Procedura in README.md, sezione "Segreti".
  fileIdentitaLavoro = "${config.xdg.configHome}/git/identita-lavoro";

  fileIdentitaPersonale = "${config.xdg.configHome}/git/identita-personale";
in
{
  programs.git = {
    enable = true;

    settings = {
      user = identitaPersonale;
      # Come su Arch (~/.gitconfig): i token HTTPS restano in
      # ~/.git-credentials, che e' un segreto e non sta nella repo.
      credential.helper = "store";
    };

    # Era ~/.config/git/ignore su Arch.
    ignores = [ "**/.claude/settings.local.json" ];

    # Git applica gli include nell'ordine in cui compaiono e l'ultimo
    # che corrisponde vince. I progetti di lavoro stanno sparsi in
    # ~/Progetti/, quelli personali in ~/Progetti/personali/: quindi
    # prima si passa all'identita' aziendale per tutto ~/Progetti/, poi
    # si torna a quella personale nella sottocartella. Cosi' non serve
    # riorganizzare le cartelle esistenti.
    #
    # Il pattern che finisce con "/" e' ricorsivo (git ci aggiunge "**").
    includes = [
      {
        condition = "gitdir:~/Progetti/";
        path = fileIdentitaLavoro;
      }
      {
        condition = "gitdir:~/Progetti/personali/";
        path = fileIdentitaPersonale;
      }
    ];
  };

  # L'identita' personale non e' un segreto, quindi questo file lo
  # genera Home Manager. Serve a rimettere a posto l'identita' dentro
  # ~/Progetti/personali/, dopo che l'include precedente l'ha cambiata
  # per tutto ~/Progetti/.
  xdg.configFile."git/identita-personale".text = ''
    [user]
    	name = ${identitaPersonale.name}
    	email = ${identitaPersonale.email}
  '';
}
