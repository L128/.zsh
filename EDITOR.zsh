if [[ -n $SSH_CONNECTION ]]; then
  # 远程会话使用 nano 或 vim
  export EDITOR='nano'
else
  # 本地会话使用 Sublime Text
  # export EDITOR='subl -w'
  # 本地会话使用 VSCode
  export EDITOR='code -w'
fi