# 覆盖 helmfile 命令以保护危险操作
helmfile() {
  # 检查是否是危险的 destroy 命令，修复了引号闭合问题
  if [[ "$@" == "destroy" || "$@" == "-e prod destroy" ]]; then
    echo "Don't do it! PVC will be deleted. Come change helmfile_protection.zsh if you really want to do it."
    return 1
  fi
  
  # 对于其他命令，正常执行原始的 helmfile
  command helmfile "$@"
}
