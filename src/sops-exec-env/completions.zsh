#compdef sops-exec-env

function _sops-exec-env() {
  _arguments -C '*:: :_normal'
}

if [ "$funcstack[1]" = "_sops-exec-env" ]; then
  _sops-exec-env "$@"
else
  compdef _sops-exec-env @sops-exec-env
fi
