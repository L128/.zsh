#!/bin/zsh
# 自定义 brew 命令，覆盖 update 子命令
brew() {
  if [ "$1" = "u" ]; then
    echo "=== 开始全量 Brew 管理（安装+更新）==="
    echo
    # 先更新 brew 自身索引（确保能获取最新软件版本）
    brew update -v
    echo
    # 获取当前设备名
    local device_name=$(hostname)
    manage_brew_formulas
    manage_brew_casks "$device_name"
    brew upgrade
    echo "=== 全量 Brew 管理完成 ===" 
  elif [ "$1" = "install" ] && [ "$2" = "brew" ]; then
    # /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  elif [ "$1" = "uninstall" ] && [ "$2" = "brew" ]; then
    sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    sudo rm -rf /opt/homebrew
    rm -rf ~/Library/Caches/Homebrew
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
  "fluxcd/tap/flux"
  "miniconda"
  "kustomize"
  "repomix"
  "telnet"
  "wget"
  "hugo"
)

# 定义通用的 brew cask 列表（所有设备都安装）
local BREW_CASKS_COMMON=(
  "visual-studio-code"
  "iterm2"
  "warp"
  "sonos"
  "font-maple-mono-nf-cn"
  "squirrel-app"
  "alfred"
  "bartender"
  "pronotes"
  "hugo"
)

# 定义非工作设备的 brew cask 列表
local BREW_CASKS_NONWORK=(
  "wechat"
  # "surge"
  "trae-cn"
  "whatsapp"
  # "container"
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
# 参数：
#   $1 - 设备名（hostname）
manage_brew_casks() {
  local hostname="$1"
  echo "=== 开始管理 Brew Cask ==="
  echo "当前设备名: $hostname"
  
  # 先安装所有设备通用的 cask
  for cask in "${BREW_CASKS_COMMON[@]}"; do
    # 检测 Cask 是否已安装（--cask 参数指定检查 Cask）
    if brew list --cask "$cask" &>/dev/null; then
      echo "✅ $cask 已安装，开始更新..."
      # brew upgrade --cask "$cask" --no-quarantine
      brew upgrade --cask "$cask" -f
    else
      echo "❌ $cask 未安装，开始安装..."
      # brew install --cask "$cask" --no-quarantine
      brew install --cask "$cask" -f
    fi
  done
  
  # 如果设备名不为 LouWorkMBP14.local，则安装非工作设备的 cask
  if [ "$hostname" != "LouWorkMBP14.local" ]; then
    echo "=== 设备名不为 LouWorkMBP14.local，安装非工作设备的 Cask 应用 ==="
    for cask in "${BREW_CASKS_NONWORK[@]}"; do
      if brew list --cask "$cask" &>/dev/null; then
        echo "✅ $cask 已安装，开始更新..."
        brew upgrade --cask "$cask" -f
      else
        echo "❌ $cask 未安装，开始安装..."
        brew install --cask "$cask" -f
      fi
    done
  fi
  
  echo "=== Cask 管理完成 ==="
  echo
}