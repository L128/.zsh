#!/bin/zsh
flux() {
  if [ "$1" = "rebuild" ]; then
    cd ~/Documents/GitLab/homelab
    git status
    git add .
    git commit -m "Auto commit by flux rebuild"
    git push origin main
    flux reconcile kustomization flux-system --with-source -n flux-system
  else
    # 其他 brew 命令（如 install、upgrade 等）正常执行
    command flux "$@"
  fi
}
