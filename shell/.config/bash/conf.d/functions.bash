function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

lg() {
  export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
  lazygit "$@"
  if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
    cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
    rm -f $LAZYGIT_NEW_DIR_FILE >/dev/null
  fi
}

function pdf() {
  # Busca archivos pdf, los pasa por fzf y abre el seleccionado con zathura
  # El '&' final es para que zathura corra en segundo plano y no bloquee tu terminal
  local file
  file=$(find ${1:-.} -name "*.pdf" | fzf)
  [ -n "$file" ] && zathura "$file" &
  disown
}
