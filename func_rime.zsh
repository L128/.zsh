rime() {
  if [ "$1" = "update" ]; then
    ansible-playbook ~/.ansible/playbooks/rime/rime_update.yml
  elif [ "$1" = "sync" ]; then
    ansible-playbook ~/.ansible/playbooks/rime/rime_sync.yml
  else
    echo "用法:"
    echo "  rime update  - 更新 Rime 配置仓库"
    echo "  rime sync    - 更新 Rime 跨设备同步配置"
  fi
}