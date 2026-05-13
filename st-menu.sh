#!/data/data/com.termux/files/usr/bin/bash

set -e

# ==============================
# SillyTavern 安卓一键菜单
# by jimmyNIE-0901
# ==============================

GITHUB_USER="jimmyNIE-0901"
REPO_NAME="sillytavern-termux-installer"
BRANCH="main"

MENU_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/st-menu.sh"
MENU_PATH="$HOME/st-menu.sh"

ST_DIR="$HOME/SillyTavern"
ST_REPO="https://github.com/SillyTavern/SillyTavern.git"
ST_BRANCH="release"
PORT="8000"

BASHRC="$HOME/.bashrc"
AUTO_MARK_START="# >>> SillyTavern Menu Auto Start >>>"
AUTO_MARK_END="# <<< SillyTavern Menu Auto Start <<<"

line() {
  echo "────────────────────────────────────"
}

title() {
  clear
  echo "╭────────────────────────────────────╮"
  echo "│       SillyTavern 安卓小助手        │"
  echo "│          酒馆一键部署菜单          │"
  echo "╰────────────────────────────────────╯"
  echo
}

pause() {
  echo
  read -r -p "按回车回到菜单..."
}

safe_cd_st() {
  if [ ! -d "$ST_DIR" ]; then
    echo "还没找到 SillyTavern 文件夹。"
    echo "先去菜单里选 1 安装酒馆吧。"
    pause
    return 1
  fi

  cd "$ST_DIR"
}

install_deps() {
  line
  echo "正在整理 Termux 环境..."
  echo "小猫开始翻工具箱：git、nodejs-lts、python、curl、nano。"
  line

  pkg update -y
  pkg upgrade -y
  pkg install -y git nodejs-lts python curl nano
}

install_st() {
  title
  echo "准备安装 SillyTavern。"
  echo "这一步会下载酒馆本体，并安装需要的 npm 依赖。"
  echo

  install_deps

  if [ -d "$ST_DIR/.git" ]; then
    echo
    echo "已经检测到 SillyTavern："
    echo "$ST_DIR"
    echo
    echo "不用重复安装啦。想拿最新版的话，选 2 更新酒馆。"
    pause
    return
  fi

  if [ -d "$ST_DIR" ]; then
    echo
    echo "发现已有 SillyTavern 文件夹，但它看起来不是 Git 仓库。"
    echo "为了避免误伤你的文件，我不会直接覆盖它。"
    echo
    echo "你可以手动改名或删除这个文件夹后，再回来安装："
    echo "$ST_DIR"
    pause
    return
  fi

  echo
  line
  echo "正在下载 SillyTavern release 分支..."
  line

  git clone -b "$ST_BRANCH" "$ST_REPO" "$ST_DIR"

  cd "$ST_DIR"

  echo
  line
  echo "正在安装 npm 依赖..."
  echo "第一次会慢一点，安心等待，不要把Termux关掉！"
  line

  npm install

  echo
  line
  echo "安装完成。"
  echo "启动后浏览器打开："
  echo "http://127.0.0.1:$PORT"
  line

  pause
}

update_st() {
  title

  if ! safe_cd_st; then
    return
  fi

  echo "准备更新 SillyTavern。"
  echo "如果你改过酒馆本体文件，我会先帮你 stash 保存一下。"
  echo

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "检测到本地有改动。"
    echo "正在自动备份到 git stash..."
    git stash push -m "auto-backup-before-update-$(date +%Y%m%d-%H%M%S)"
    echo
  fi

  line
  echo "正在切换到 ${ST_BRANCH} 分支..."
  line

  git fetch origin
  git checkout "$ST_BRANCH"

  line
  echo "正在拉取更新..."
  line

  git pull --ff-only origin "$ST_BRANCH"

  line
  echo "正在更新 npm 依赖..."
  line

  npm install

  echo
  line
  echo "酒馆更新完成。"
  echo "可以回菜单选 3 启动。"
  line

  pause
}

start_st() {
  title

  if ! safe_cd_st; then
    return
  fi

  echo "准备启动 SillyTavern。"
  echo
  echo "启动成功后，手机浏览器打开："
  echo "http://127.0.0.1:$PORT"
  echo
  echo "想停止酒馆，就回到 Termux 按 Ctrl + C。"
  echo "不要直接关后台哦。"
  echo

  line
  termux-wake-lock 2>/dev/null || true
  node server.js
}

repair_npm() {
  title

  if ! safe_cd_st; then
    return
  fi

  echo "准备修复 npm 依赖。"
  echo "适合这种情况：启动报错、依赖缺失、更新后怪怪的。"
  echo
  echo "我会删除 node_modules 和 package-lock.json，然后重新安装。"
  echo

  read -r -p "确认修复吗？输入 y 继续： " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo
    echo "已取消。挺好，谨慎点₍ᵔ･•･ᵔ₎。"
    pause
    return
  fi

  line
  echo "正在清理旧依赖..."
  line

  rm -rf node_modules package-lock.json

  line
  echo "正在重新安装 npm 依赖..."
  line

  npm install

  echo
  line
  echo "npm 依赖修复完成。"
  line

  pause
}

rollback_previous_commit() {
  title

  if ! safe_cd_st; then
    return
  fi

  echo "准备回退到上一个 SillyTavern 版本。"
  echo
  echo "这个功能会把酒馆本体代码退回上一个 git 版本。"
  echo "适合刚更新完发现酒馆炸了、页面怪了、插件不兼容了。"
  echo
  echo "一般不会动你的角色卡、世界书和聊天记录。"
  echo "但如果你很宝贝数据，更新和回退前都建议自己备份一下。"
  echo

  read -r -p "确认回退到上一个版本吗？输入 y 继续： " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo
    echo "已取消。挺好，没想清楚之前别乱按₍ᵔ･•･ᵔ₎"
    pause
    return
  fi

  line
  echo "正在回退到上一个版本..."
  line

  git reset --hard HEAD~1

  line
  echo "正在重新整理 npm 依赖..."
  line

  npm install

  echo
  line
  echo "回退完成。"
  echo "现在可以回菜单选 3 启动 SillyTavern。"
  line

  pause
}

update_menu_script() {
  title

  echo "准备更新这个一键菜单脚本。"
  echo "会从 GitHub 重新下载最新版 st-menu.sh。"
  echo
  echo "来源："
  echo "$MENU_URL"
  echo

  pkg install -y curl >/dev/null 2>&1 || true

  line
  echo "正在下载最新版菜单..."
  line

  curl -fsSL "$MENU_URL" -o "$MENU_PATH"
  chmod +x "$MENU_PATH"

  echo
  line
  echo "菜单脚本更新完成。"
  echo "重新打开 Termux，或者输入下面这句立即进入新版菜单："
  echo "bash ~/st-menu.sh"
  line

  pause
}

disable_auto_start() {
  title

  echo "准备关闭：打开 Termux 自动进入酒馆菜单。"
  echo

  if [ -f "$BASHRC" ]; then
    sed -i "/$AUTO_MARK_START/,/$AUTO_MARK_END/d" "$BASHRC"
    echo "已经关闭自动进入菜单。"
  else
    echo "没有找到 ~/.bashrc，不需要处理。"
  fi

  echo
  echo "以后想手动打开菜单，输入："
  echo "bash ~/st-menu.sh"

  pause
}

enable_auto_start() {
  title

  echo "准备开启：打开 Termux 自动进入酒馆菜单。"
  echo

  if [ -f "$BASHRC" ]; then
    sed -i "/$AUTO_MARK_START/,/$AUTO_MARK_END/d" "$BASHRC"
  fi

  cat >> "$BASHRC" <<EOF

$AUTO_MARK_START
if [ -t 1 ] && [ -f "\$HOME/st-menu.sh" ]; then
  bash "\$HOME/st-menu.sh"
fi
$AUTO_MARK_END
EOF

  echo "已经开启自动进入菜单。"
  echo "下次打开 Termux 就会直接来到这里。"

  pause
}

show_info() {
  title

  echo "当前配置"
  line
  echo "酒馆安装路径：$ST_DIR"
  echo "酒馆分支：$ST_BRANCH"
  echo "默认端口：$PORT"
  echo "本机访问：http://127.0.0.1:$PORT"
  echo "菜单脚本：$MENU_PATH"
  echo "菜单来源：$MENU_URL"
  line
  echo
  echo "常见小问题"
  echo
  echo "1. 浏览器打不开"
  echo "   先看 Termux 里有没有报错。酒馆运行时不能关掉 Termux。"
  echo
  echo "2. 第一次 npm install 很慢"
  echo "   正常。就是比较慢，等等吧₍ᵔ･•･ᵔ₎。"
  echo
  echo "3. 手机锁屏后断了"
  echo "   安卓省电策略可能杀后台，可以给 Termux 关掉电池优化。"
  echo
  echo "4. 更新失败"
  echo "   可以先选 4 修复 npm 依赖，再试一次。"
  echo
  echo "5. 回退版本"
  echo "   选 6 可以回退到上一个酒馆 git 版本。"
  echo "   适合刚更新完就炸的情况。"
  echo

  pause
}

uninstall_menu_only() {
  title

  echo "这个功能只删除一键菜单，不删除 SillyTavern 本体。"
  echo
  echo "会处理："
  echo "- 关闭 Termux 自动进入菜单"
  echo "- 删除 ~/st-menu.sh"
  echo
  echo "不会处理："
  echo "- ~/SillyTavern"
  echo "- 你的角色卡、世界书、聊天记录"
  echo

  read -r -p "确认删除菜单吗？输入 y 继续： " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo
    echo "已取消。"
    pause
    return
  fi

  if [ -f "$BASHRC" ]; then
    sed -i "/$AUTO_MARK_START/,/$AUTO_MARK_END/d" "$BASHRC"
  fi

  rm -f "$MENU_PATH"

  echo
  echo "菜单已删除。"
  echo "SillyTavern 本体还在：$ST_DIR"
  echo
  echo "你可以关闭 Termux 了。"
  exit 0
}

main_menu() {
  while true; do
    title

    echo "今天想对酒馆做什么？"
    echo
    echo "  1. 安装 SillyTavern"
    echo "  2. 更新 SillyTavern"
    echo "  3. 启动 SillyTavern"
    echo "  4. 修复 npm 依赖"
    echo "  5. 查看说明"
    echo
    echo "  6. 回退到上一个酒馆版本"
    echo "  7. 更新这个一键菜单"
    echo "  8. 开启打开 Termux 自动进入菜单"
    echo "  9. 关闭打开 Termux 自动进入菜单"
    echo
    echo "  10. 只删除这个菜单"
    echo "  0. 退出"
    echo
    line

    read -r -p "请选择： " choice

    case "$choice" in
      1) install_st ;;
      2) update_st ;;
      3) start_st ;;
      4) repair_npm ;;
      5) show_info ;;
      6) rollback_previous_commit ;;
      7) update_menu_script ;;
      8) enable_auto_start ;;
      9) disable_auto_start ;;
      10) uninstall_menu_only ;;
      0)
        echo
        echo "好，先关门。下次来酒馆记得带钥匙。"
        exit 0
        ;;
      *)
        echo
        echo "没有这个选项，别乱戳。"
        sleep 1
        ;;
    esac
  done
}

main_menu
