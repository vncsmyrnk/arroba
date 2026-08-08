{
  lib,
  pkgs,
}:

pkgs.writeShellScriptBin "git-worktree-cd" ''
  export PATH="${
    lib.makeBinPath [
      pkgs.git
      pkgs.fzf
      pkgs.coreutils
      pkgs.gawk
    ]
  }"
    if ! path=$(git worktree list |
      fzf --height=~10 |
      awk '{ print $1 }'); then
      echo "error: $path" >&2
      exit 1
    fi
    builtin cd "$path" || exit 1
    echo "entering nested subshell"
    exec "$SHELL"
''
