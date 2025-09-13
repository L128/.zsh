update() {
  if [ "$1" = "rime" ]; then
    cd ~/Library/Rime && git pull
    # 发送同步通知给正在运行的鼠鬚管进程
    /Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --sync
    /Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --build
  else
    echo "用法:"
    echo "  update rime - 更新 Rime 跨设备词库"
  fi
}