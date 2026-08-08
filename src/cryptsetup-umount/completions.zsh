# vim: set ft=zsh:

#compdef cryptsetup-umount

function _cryptsetup-umount() {
  local context state state_descr line
  typeset -A opt_args
  local ret=1

  _arguments -C \
    '1:Container image file:->action' && ret=0

  case $state in
  action)
    _files
    choices=(${(f)"$(_call_program command ls "$HOME/.config/utilities/cryptsetup" | while read -r f; do
      basename "$f" | rev | cut -f2 -d "." | rev
    done)"})
    _describe 'commands' choices && ret=0
    ;;
  esac

  return ret
}

if [ "$funcstack[1]" = "_cryptsetup-umount" ]; then
  _cryptsetup-umount "$@"
else
  compdef _cryptsetup-umount @cryptsetup-umount
fi
