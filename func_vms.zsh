# 定义带空格的"别名"（实际是函数）
vms() {
  if [ "$1" = "update" ]; then
    # 当输入 vms update 时执行的命令
    ansible-playbook -i ~/.ansible/inventory/hosts ~/.ansible/playbooks/apt.yaml
  else
    # 可选：处理其他参数或提示错误
    echo "未知命令: vms $1"
  fi
}