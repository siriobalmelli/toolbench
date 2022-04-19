## toolbench scripts, for installation on a running system
# TODO: de-facto 'ghostscript' dependency for merge_pdf is not encoded anywhere
{ writeShellScriptBin, syncthing }:

{
  tbh_flush_dns = writeShellScriptBin "tbh_flush_dns"
    (builtins.readFile ./flush_dns.sh);
  tbh_gemset_nix = writeShellScriptBin "tbh_gemset_nix"
    (builtins.readFile ./gemset_nix.sh);
  tbh_iconify = writeShellScriptBin "tbh_iconify"
    (builtins.readFile ./iconify.sh);
  tbh_install = writeShellScriptBin "tbh_install"
    (builtins.readFile ./install.sh);
  tbh_mac_tftp = writeShellScriptBin "tbh_mac_tftp"
    (builtins.readFile ./mac_tftp.sh);
  tbh_merge_pdf = writeShellScriptBin "tbh_merge_pdf"
    (builtins.readFile ./merge_pdf.sh);
  tbh_pyenv = writeShellScriptBin "tbh_pyenv"
    (builtins.readFile ./pyenv.sh);
  tbh_rpush = writeShellScriptBin "tbh_rpush"
    (builtins.readFile ./rpush.sh);
  tbh_syncthing = writeShellScriptBin "tbh_syncthing" ''
    case "$(uname)" in
      Darwin) LOGDIR="$HOME/Library/Application Support/Syncthing" ;;
      Linux)  LOGDIR="$HOME/.config/syncthing" ;;
    esac
    ${syncthing}/bin/syncthing -logfile="$LOGDIR/log" & >>"$LOGDIR/log" 2>&1
    disown %1
  '';
  tbh_tarify = writeShellScriptBin "tbh_tarify"
    (builtins.readFile ./tarify.sh);
  tbh_unixify = writeShellScriptBin "tbh_unixify" ''
    find ./ -type f -exec file --mime-type "{}" \; \
      | sed -nE 's/(.*): text\/.*/\1/p' \
      | xargs -P$(nproc) -I{} dos2unix -v -s "{}"
  '';
  tbh_zfsmon = writeShellScriptBin "tbh_zfsmon" ''
    watch -- 'zpool iostat -yl 1 1; echo; zfs get usedbydataset,refcompressratio'
  '';
}
