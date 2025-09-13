# .zsh 配置模块

这是一个模块化的 Zsh 配置文件集合，用于增强 macOS 终端体验。通过将这些配置导入到你的 `.zshrc` 文件中，可以极大地提升工作效率。

## 功能概览

### 编辑器配置
- [EDITOR.zsh](EDITOR.zsh) - 根据连接类型自动设置编辑器，远程连接使用 nano，本地连接使用 VSCode

### 别名设置
- [alias.zsh](alias.zsh) - kubectl 命令别名，简化 Kubernetes 操作：
  - `k` = `kubectl`
  - `kg` = `kubectl get`
  - `kgp` = `kubectl get pods`
  - 等等...

### 自定义功能函数

#### Brew 管理
- [func_brew.zsh](func_brew.zsh) - 扩展 brew 命令：
  - `brew u` - 一键更新/安装预定义的 formulas 和 casks
  - `brew ua` - 运行 Ansible playbook（预留）
  - `brew addtaps` - 添加预定义的 taps

#### 安装工具
- [func_install.zsh](func_install.zsh) - 简化常用工具安装：
  - `install brew` - 通过国内源安装 Homebrew
  - `install ansible` - 安装 Ansible

#### Rime 输入法管理
- [func_rime.zsh](func_rime.zsh) - 管理 Rime 输入法配置：
  - `rime update` - 更新 Rime 配置仓库
  - `rime sync` - 同步 Rime 跨设备配置

#### 系统更新工具
- [func_update.zsh](func_update.zsh) - 系统更新功能：
  - `update rime` - 更新 Rime 词库

#### 服务重启工具
- [func_restart.zsh](func_restart.zsh) - 服务管理：
  - `restart icloud` - 重启 macOS 的 iCloud 文件同步服务

#### Helmfile 保护机制
- [helmfile_protection.zsh](helmfile_protection.zsh) - 防止危险的 helmfile 操作：
  - 阻止 `helmfile destroy` 命令以保护持久卷不被删除

#### 虚拟机管理
- [func_vms.zsh](func_vms.zsh) - 虚拟机管理功能（根据文件名推测）

### 配置导入
- [customized.zsh](customized.zsh) - 主配置文件，导入所有功能模块

## 使用方法

将以下代码添加到你的 `~/.zshrc` 文件中：

```bash
source ~/.zsh/customized.zsh
```

## 功能模块详解

### Brew 管理扩展

Brew 管理功能预定义了常用的 formulas 和 casks：

**Formulas:**
- git
- kubectl
- ansible
- helm
- chezmoi
- ansible-lint

**Casks:**
- visual-studio-code
- iterm2
- warp
- sonos
- font-maple-mono-nf-cn
- squirrel-app (Rime 输入法)
- alfred

使用 `brew u` 命令可以一键检查并安装或更新这些软件包。

### 安全特性

[helmfile_protection.zsh](helmfile_protection.zsh) 提供了安全保护机制，防止意外执行危险的 `helmfile destroy` 命令，避免删除重要的持久卷数据。

## 自定义配置

你可以根据个人需求修改以下文件：
1. [func_brew.zsh](func_brew.zsh) - 修改预定义的 formulas 和 casks 列表
2. [alias.zsh](alias.zsh) - 添加或修改命令别名
3. [EDITOR.zsh](EDITOR.zsh) - 调整编辑器配置
4. [helmfile_protection.zsh](helmfile_protection.zsh) - 修改 Helmfile 保护规则