#compdef oathtool-totp-generate

function _oathtool-totp-generate() {
  local context state state_descr line
  typeset -A opt_args
  local ret=1

  _arguments -C \
    '1:Container image file:->action' && ret=0

  case $state in
  action)
    choices=(${(f)"$(_call_program command ls "$HOME/.config/utilities/oathtool" | while read -r f; do
      basename "$f" | rev | cut -f2 -d "." | rev
    done)"})
    _describe 'commands' choices && ret=0
    ;;
  esac

  return ret
}

if [ "$funcstack[1]" = "_oathtool-totp-generate" ]; then
  _oathtool-totp-generate "$@"
else
  compdef _oathtool-totp-generate @oathtool-totp-generate
fi
