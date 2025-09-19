# 检查并添加必要的brew tap仓库
check_and_add_tap() {
    local tap_name="$1"
    
    # 检查tap是否已添加
    if ! brew tap | grep -q "^$tap_name$"; then
        echo "正在添加 brew tap: $tap_name"
        brew tap "$tap_name"
        if [ $? -eq 0 ]; then
            echo "成功添加 $tap_name"
        else
            echo "添加 $tap_name 失败"
        fi
    else
        echo "brew tap $tap_name 已存在"
    fi
}


# 检查并添加需要的tap仓库
check_and_add_tap "brewforge/chinese"
check_and_add_tap "brewforge/extras"


