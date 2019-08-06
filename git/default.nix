# Git, with a git config baked in (see ./config)
{ git, symlinkJoin, makeWrapper, writeScriptBin }:

{
  bin = symlinkJoin {
    name = "git";
    buildInputs = [makeWrapper];
    paths = [git];
    postBuild = ''
      wrapProgram "$out/bin/git" \
      --set GCRYPT_FULL_REPACK 1
    '';
    # Do NOT set GIT_CONFIG ... any tool e.g. gcrypt running 'git config'
    # will thereafter modify the global config (which is super annoying).
    # Rely on "impure" handling where 'homies-gitconfig' is written to homedir
    # by tbh_install.
      # --set GIT_CONFIG "${./gitconfig}" \
  };

  # temporary measure: output a script to clobber .gitconfig
  # This is because git is ignoring GIT_CONFIG
  # (see git-env-check.sh and related bug report on git mailing list)
  # write a script that sources it
  script = writeScriptBin "homies-gitconfig"
    ''
    cat ${./gitconfig}
    '';
}
