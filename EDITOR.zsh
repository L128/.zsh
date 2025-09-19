if [[ -n $SSH_CONNECTION ]]; then
  # 远程会话使用 nano 或 vim
  export EDITOR='nano'
else
  # 本地会话根据设备名选择编辑器
  local hostname=$(hostname)
  if [ "$hostname" = "LouWorkMBP14.local" ]; then
    # 工作设备使用 VSCode
    export EDITOR='code -w'
  else
    # 非工作设备使用 Trae
    export EDITOR='trae -w'
  fi
fi