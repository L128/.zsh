#!/bin/zsh
# 自定义 brew 命令，覆盖 update 子命令
brew() {
  if [ "$1" = "ua" ]; then
    # 当执行 brew update 时，运行 ansible 剧本
    # ansible-playbook -i ~/.ansible/inventory/hosts ~/.ansible/playbooks/brew_update.yml
    # ansible-playbook ~/.ansible/playbooks/brew_update.yml
  elif [ "$1" = "u" ]; then
    echo "=== 开始全量 Brew 管理（安装+更新）==="
    echo
    # 先更新 brew 自身索引（确保能获取最新软件版本）
    brew update -v
    echo
    manage_brew_formulas
    manage_brew_casks
    echo "=== 全量 Brew 管理完成 ===" 
  elif [ "$1" = "addtaps" ]; then
    source ~/.zsh/brew-add-tap.zsh
  else
    # 其他 brew 命令（如 install、upgrade 等）正常执行
    command brew "$@"
  fi
}


# 定义需要更新的 brew formula 列表（可根据需求添加/删除）
local BREW_FORMULAS=(
  "git"
  "kubectl"
  "ansible"
  "helm"
  "chezmoi"
  "ansible-lint"
)

# 定义需要更新的 brew cask 列表（可根据需求添加/删除）
local BREW_CASKS=(
  # "google-chrome"
  "visual-studio-code"
  "iterm2"
  "warp"
  "sonos"
  "font-maple-mono-nf-cn"
  "squirrel-app"
  "alfred"
)
# 函数：处理 Formula（未安装则安装，已安装则更新）
manage_brew_formulas() {
  echo "=== 开始管理 Brew Formula ==="
  for formula in "${BREW_FORMULAS[@]}"; do
    # 检测 Formula 是否已安装（brew list 静默检查，仅返回状态码）
    if brew list --formula "$formula" &>/dev/null; then
      echo "✅ $formula 已安装，开始更新..."
      brew upgrade "$formula"
    else
      echo "❌ $formula 未安装，开始安装..."
      brew install "$formula"
    fi
  done
  echo "=== Formula 管理完成 ==="
  echo
}

# 函数：处理 Cask（未安装则安装，已安装则更新）
manage_brew_casks() {
  echo "=== 开始管理 Brew Cask ==="
  for cask in "${BREW_CASKS[@]}"; do
    # 检测 Cask 是否已安装（--cask 参数指定检查 Cask）
    if brew list --cask "$cask" &>/dev/null; then
      echo "✅ $cask 已安装，开始更新..."
      # brew upgrade --cask "$cask" --no-quarantine
      brew upgrade --cask "$cask" -f
    else
      echo "❌ $cask 未安装，开始安装..."
      # brew install --cask "$cask" --no-quarantine
      brew install --cask "$cask"
    fi
  done
  echo "=== Cask 管理完成 ==="
  echo
}