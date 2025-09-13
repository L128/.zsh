restart() {
    if [ "$1" = "icloud" ]; then
        # 重启macOS的iCloud文件同步服务(bird进程)
        echo "=== 开始重启iCloud文件同步服务 ==="

        # 检查bird进程是否存在
        echo "1. 检查bird进程状态..."
        BIRD_PID=$(pgrep -f "/System/Library/CoreServices/bird")

        if [ -z "$BIRD_PID" ]; then
            echo "   未发现运行中的bird进程，尝试启动..."
        else
            echo "   发现运行中的bird进程，PID: $BIRD_PID"
            
            # 终止bird进程
            echo "2. 终止bird进程..."
            if sudo pkill -f "/System/Library/CoreServices/bird"; then
                echo "   成功终止bird进程"
            else
                echo "   终止bird进程失败"
                exit 1
            fi
            
            # 等待片刻
            echo "3. 等待进程重启..."
            sleep 2
        fi

        # 检查进程是否重启
        echo "4. 验证bird进程状态..."
        NEW_BIRD_PID=$(pgrep -f "/System/Library/CoreServices/bird")

        if [ -n "$NEW_BIRD_PID" ]; then
            echo "   iCloud文件同步服务已重启，新PID: $NEW_BIRD_PID"
            echo "=== 操作完成 ==="
        else
            echo "   警告：bird进程未自动重启"
            echo "   建议手动重启电脑或检查iCloud设置"
            echo "=== 操作完成但可能存在问题 ==="
            exit 1
        fi
    else
    echo "用法:"
    echo "  restart icloud  - 重启macOS的iCloud文件同步服务(bird进程)"
    fi
}