install() {
  if [ "$1" = "brew" ]; then
    # 检查并安装Homebrew
    if ! command -v brew &> /dev/null; then
      echo "Homebrew未安装，正在通过Gitee源安装..."
      # 使用Gitee的Homebrew安装脚本
      /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
      # 刷新环境变量使brew生效
      if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    else
      echo "Homebrew已安装，跳过安装步骤。"
    fi
  elif [ "$1" = "ansible" ]; then
    # 检查并安装ansible
    if ! brew list ansible &> /dev/null; then
      echo "ansible未安装，正在通过Homebrew安装..."
      brew install ansible
    else
      echo "ansible已安装，跳过安装步骤。"
    fi
  else 
    echo "用法:"
    echo "  install brew  - 从Gitee国内源脚本安装Homebrew"
    echo "  install ansible - 通过Homebrew安装Ansible"
  fi
}