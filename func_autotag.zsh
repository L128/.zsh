#!/usr/bin/env zsh

# 主命令入口
autotag() {
    # 配置与常量（局部变量，仅在autotag函数内可见）
    local TAG_PREFIX="V"
    local DEFAULT_VERSION="1.0.0"
    local DEFAULT_BRANCH="main"  # 可配置的默认分支名称
    local RED="\033[31m"
    local GREEN="\033[32m"
    local YELLOW="\033[33m"
    local RESET="\033[0m"

    # 内部辅助函数：显示帮助信息（补充提交前置说明）
    __autotag_show_help() {
        echo -e "\n${YELLOW}Usage: autotag [COMMAND]${RESET}"
        echo -e "自动递增Git Tag版本号并同步更新默认分支（适配Hugo+Blowfish项目）\n"
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
    __autotag_get_latest() {
        local latest_tag
        latest_tag=$(git describe --abbrev=0 --tags 2>/dev/null)
        
        if [ -z "$latest_tag" ]; then
            echo -e "${YELLOW}⚠️  未检测到现有Git Tag，将使用默认版本 ${TAG_PREFIX}${DEFAULT_VERSION}${RESET}"
            echo -n "${TAG_PREFIX}${DEFAULT_VERSION}"  # 使用-n参数确保不输出额外的换行符
        else
            echo -n "$latest_tag"  # 使用-n参数确保不输出额外的换行符
        fi
    }

    # 内部辅助函数：解析版本号（过滤掉颜色代码和emoji）
    __autotag_parse() {
        local tag="$1"
        # 过滤掉ANSI颜色代码
        local clean_tag=$(echo "$tag" | sed 's/\x1b\[[0-9;]*m//g')
        # 过滤掉emoji和其他非ASCII字符
        clean_tag=$(echo "$clean_tag" | LC_CTYPE=C sed 's/[^[:print:]]//g')
        local version=${clean_tag#$TAG_PREFIX}
        IFS='.' read -r major minor patch <<< "$version"
        echo "$major $minor $patch"
    }

    # 内部辅助函数：递增版本号（包含输入验证）
    __autotag_increment() {
        local major="$1"
        local minor="$2"
        local patch="$3"
        local increment_type="$4"

        # 输入验证：确保版本号部分为数字
        if ! [[ "$major" =~ ^[0-9]+$ ]]; then
            major=0
        fi
        if ! [[ "$minor" =~ ^[0-9]+$ ]]; then
            minor=0
        fi
        if ! [[ "$patch" =~ ^[0-9]+$ ]]; then
            patch=0
        fi

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
            patch)
                patch=$((patch + 1))
                ;;
        esac

        echo "${TAG_PREFIX}${major}.${minor}.${patch}"
    }

    # 内部主逻辑执行函数
    __autotag_execute() {
        local increment_type="$1"

        # 检查是否在Git仓库
        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo -e "${RED}❌ 当前目录不是Git仓库，请进入项目根目录后执行${RESET}"
            return 1
        fi

        # 检查是否有未提交的变更（新增提示）
        if ! git diff --quiet --exit-code; then
            echo -e "${YELLOW}⚠️  检测到未提交的变更，建议先执行 git commit 提交后再创建标签${RESET}"
            read -p "是否继续创建标签（可能关联到旧提交）？[y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}⚠️  操作已取消，请先提交变更${RESET}"
                return 1
            fi
        fi

        # 执行版本号更新流程
        echo -e "${GREEN}🔍 正在检测最新Git Tag...${RESET}"
        local latest_tag=$(__autotag_get_latest)
        local -a version_parts=($(__autotag_parse "$latest_tag"))
        local new_tag=$(__autotag_increment "${version_parts[0]}" "${version_parts[1]}" "${version_parts[2]}" "$increment_type")

        echo -e "${GREEN}✅ 计算新版本号：$new_tag（${increment_type}递增）${RESET}"
        echo -e "${GREEN}📦 正在创建Git Tag...${RESET}"
        git tag -a "$new_tag" -m "Release $new_tag"
        echo -e "${GREEN}🚀 正在推送Tag到远程...${RESET}"
        git push origin "$new_tag"
        
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
        help)
            __autotag_show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令：$command，使用 autotag help 查看可用命令${RESET}"
            return 1
            ;;
    esac
}
