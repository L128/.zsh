#!/usr/bin/env zsh

# 主命令入口
autotag() {
    # 配置与常量（在函数内部定义，保持封装性）
    local TAG_PREFIX="V"
    local DEFAULT_VERSION="1.0.0"
    local DEFAULT_BRANCH="main"  # 可配置的默认分支名称
    local RED="\033[31m"
    local GREEN="\033[32m"
    local YELLOW="\033[33m"
    local RESET="\033[0m"

    # 内部辅助函数：显示帮助信息（补充提交前置说明）
    local __autotag_show_help() {
        echo -e "\n${YELLOW}Usage: autotag [COMMAND]${RESET}"
        echo -e "自动递增Git Tag版本号并同步更新默认分支"
        echo -e "注意：使用前请确保已通过 git commit 提交所有变更，标签将关联最新提交\n"
        echo -e "功能特点："
        echo -e "  - 自动递增版本号（major/minor/patch）"
        echo -e "  - 创建并推送Git Tag到远程仓库"
        echo -e "  - 自动同步更新${DEFAULT_BRANCH}分支（拉取最新更改、合并当前分支、推送更新）\n"
        echo -e "Commands:"
        echo -e "  patch        递增修订号（默认，V1.2.3 → V1.2.4）"
        echo -e "  minor        递增次版本号（V1.2.3 → V1.3.0）"
        echo -e "  major        递增主版本号（V1.2.3 → V2.0.0）"
        echo -e "  help         显示帮助信息\n"
        echo -e "Examples:"
        echo -e "  # 1. 先提交变更"
        echo -e "  git add ."
        echo -e "  git commit -m '修复页脚样式问题'"
        echo -e "  # 2. 再创建并推送标签（同时同步更新${DEFAULT_BRANCH}分支）"
        echo -e "  autotag          # 等同于 autotag patch"
        echo -e "  autotag minor    # 次版本号递增"
    }

    # 内部辅助函数：获取最新Tag
    local __autotag_get_latest() {
        local latest_tag
        # 优先尝试使用更可靠的方式获取最新标签（按版本号排序）
        latest_tag=$(git tag -l --sort=-version:refname "${TAG_PREFIX}*" 2>/dev/null | head -n 1)
        
        # 如果上述方法失败，回退到原始方法
        if [ -z "$latest_tag" ]; then
            latest_tag=$(git describe --abbrev=0 --tags 2>/dev/null)
        fi
        
        if [ -z "$latest_tag" ]; then
            echo -e "${YELLOW}⚠️  未检测到现有Git Tag，将使用默认版本 ${TAG_PREFIX}${DEFAULT_VERSION}${RESET}"
            echo -n "${TAG_PREFIX}${DEFAULT_VERSION}"  # 使用-n参数确保不输出额外的换行符
        else
            echo -n "$latest_tag"  # 使用-n参数确保不输出额外的换行符
        fi
    }

    # 内部辅助函数：解析版本号（使用最可靠的方法）
    local __autotag_parse() {
        # 完全重写的解析函数，避免使用任何可能有问题的zsh特性
        local tag="$1"
        
        # 移除标签前缀 - 使用更简单的方法
        local version="$tag"
        if [[ "$version" == $TAG_PREFIX* ]]; then
            version=${version#$TAG_PREFIX}
        fi
        
        # 初始化默认值
        local major=0 minor=0 patch=0
        
        # 最简单的解析方法 - 手动分割字符串
        local part1="$(echo "$version" | cut -d. -f1)"
        local part2="$(echo "$version" | cut -d. -f2)"
        local part3="$(echo "$version" | cut -d. -f3)"
        
        # 确保是数字
        if [[ "$part1" =~ ^[0-9]+$ ]]; then
            major="$part1"
        fi
        if [[ "$part2" =~ ^[0-9]+$ ]]; then
            minor="$part2"
        fi
        if [[ "$part3" =~ ^[0-9]+$ ]]; then
            patch="$part3"
        fi
        
        # 输出结果
        echo "$major $minor $patch"
    }

    # 内部辅助函数：递增版本号（使用最简单的实现）
    local __autotag_increment() {
        local tag="$1"
        local increment_type="$2"
        
        # 确保increment_type有值，默认为patch
        increment_type=${increment_type:-patch}

        # 调用解析函数获取版本号各部分，但不使用数组
        # 而是使用临时变量和基本文本处理
        local parsed_output=$(__autotag_parse "$tag")
        local major=$(echo "$parsed_output" | cut -d' ' -f1)
        local minor=$(echo "$parsed_output" | cut -d' ' -f2)
        local patch=$(echo "$parsed_output" | cut -d' ' -f3)

        # 递增逻辑
        case "$increment_type" in
            major)
                major=$((major + 1))
                minor=0
                patch=0
                ;;
            minor)
                minor=$((minor + 1))
                patch=0
                ;;
            *)
                # patch或其他任何情况，都递增patch
                patch=$((patch + 1))
                ;;
        esac

        # 返回新的版本号
        echo "${TAG_PREFIX}${major}.${minor}.${patch}"
    }

    # 内部主逻辑执行函数
    local __autotag_execute() {
        local increment_type="$1"

        # 检查是否在Git仓库
        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo -e "${RED}❌ 当前目录不是Git仓库，请进入项目根目录后执行${RESET}"
            return 1
        fi

        # 检查是否有未提交的变更（新增提示）
        if ! git diff --quiet --exit-code; then
            echo -e "${YELLOW}⚠️  检测到未提交的变更，建议先执行 git commit 提交后再创建标签${RESET}"
            # 在非交互式shell中，自动取消操作
            if [ -t 0 ]; then
                # 交互式shell - 询问用户
                read -p "是否继续创建标签（可能关联到旧提交）？[y/N] " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}⚠️  操作已取消，请先提交变更${RESET}"
                    return 1
                fi
            else
                # 非交互式shell - 直接取消
                echo -e "${YELLOW}⚠️  在非交互式环境中，操作已取消，请先提交变更${RESET}"
                return 1
            fi
        fi

        # 执行版本号更新流程
        echo -e "${GREEN}🔍 正在检测最新Git Tag...${RESET}"
        local latest_tag=$(__autotag_get_latest)
        local parsed_output=$(__autotag_parse "$latest_tag")
        local new_tag=$(__autotag_increment "$latest_tag" "$increment_type")

        echo -e "${GREEN}✅ 计算新版本号：$new_tag（${increment_type}递增）${RESET}"
        
        # 检查标签是否已存在
        if git tag -l | grep -q "^$new_tag$"; then
            echo -e "${RED}❌ 标签 '$new_tag' 已存在，请尝试使用其他版本类型：${RESET}"
            echo -e "  - autotag minor    # 递增次版本号"
            echo -e "  - autotag major    # 递增主版本号"
            return 1
        fi
        
        echo -e "${GREEN}📦 正在创建Git Tag...${RESET}"
        if ! git tag -a "$new_tag" -m "Release $new_tag"; then
            echo -e "${RED}❌ 创建标签失败，请检查错误信息并手动重试${RESET}"
            return 1
        fi
        
        echo -e "${GREEN}🚀 正在推送Tag到远程...${RESET}"
        if ! git push origin "$new_tag"; then
            echo -e "${RED}❌ 推送标签失败，请检查网络连接或权限后重试${RESET}"
            # 可选：如果推送失败，可以考虑删除本地标签
            # git tag -d "$new_tag"
            return 1
        fi
        
        # 获取当前分支名
        local current_branch
        current_branch=$(git symbolic-ref --short HEAD)
        
        # 同步更新默认分支
        if [ "$current_branch" != "$DEFAULT_BRANCH" ]; then
            echo -e "${GREEN}🔄 正在同步更新$DEFAULT_BRANCH分支...${RESET}"
            git checkout "$DEFAULT_BRANCH"
            if ! git pull origin "$DEFAULT_BRANCH" --rebase; then
                echo -e "${RED}❌ 拉取远程分支时发生冲突，请手动解决后重试${RESET}"
                git checkout "$current_branch"
                return 1
            fi
            if ! git merge --no-ff "$current_branch" -m "Merge branch '$current_branch' for release $new_tag"; then
                echo -e "${RED}❌ 合并分支时发生冲突，请手动解决后重试${RESET}"
                git checkout "$current_branch"
                return 1
            fi
            git push origin "$DEFAULT_BRANCH"
            git checkout "$current_branch"
        else
            echo -e "${GREEN}🔄 正在推送$DEFAULT_BRANCH分支更新...${RESET}"
            git push origin "$DEFAULT_BRANCH"
        fi

        echo -e "\n${GREEN}🎉 操作完成！新Tag已推送，main分支已同步更新：$new_tag${RESET}"
    }

    # 子命令解析
    local command="$1"
    case "$command" in
        ""|patch)
            __autotag_execute "patch"
            ;;
        minor)
            __autotag_execute "minor"
            ;;
        major)
            __autotag_execute "major"
            ;;
        help|--help|-h)
            # 支持多种帮助命令格式
            __autotag_show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令：$command，使用 autotag help 查看可用命令${RESET}"
            return 1
            ;;
    esac
}
