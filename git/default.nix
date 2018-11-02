# Git, with a git config baked in (see ./config)
{ git, symlinkJoin, makeWrapper, writeScriptBin }:

{
  bin = symlinkJoin {
    name = "git";
    buildInputs = [makeWrapper];
    paths = [git];
    postBuild = ''
      wrapProgram "$out/bin/git" \
      --set GIT_CONFIG "${./gitconfig}"
    '';
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
