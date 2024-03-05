if [[ -d /usr/share/doc/fzf ]]; then
  source "/usr/share/doc/fzf/examples/key-bindings.bash"
  source "/usr/share/bash-completion/completions/fzf"
elif [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  source "/opt/homebrew/opt/fzf/shell/completion.bash"
  source "/opt/homebrew/opt/fzf/shell/key-bindings.bash"
fi

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
