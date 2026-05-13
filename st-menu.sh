#!/data/data/com.termux/files/usr/bin/bash

set -e

GITHUB_USER="jimmyNIE-0901"
REPO_NAME="sillytavern-termux-installer"
BRANCH="main"

MENU_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/st-menu.sh"
INSTALL_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/install.sh"

MENU_PATH="$HOME/st-menu.sh"
BASHRC="$HOME/.bashrc"

AUTO_MARK_START="# >>> SillyTavern Menu Auto Start >>>"
AUTO_MARK_END="# <<< SillyTavern Menu Auto Start <<<"

ST_DIR="$HOME/SillyTavern"
ST_REPO="https://github.com/SillyTavern/SillyTavern.git"
ST_BRANCH="release"
PORT="8000"

line() {
  echo "────────────────────────────────────────"
}

cute_header() {
  clear
  cat <<'EOF'
╭────────────────────────────────────╮
│                                    │
│        SillyTavern 安卓小酒馆        │
│                                    │
│      安装  更新  启动  修复  管理      │
│                                    │
╰────────────────────────────────────╯
EOF
  echo
}

pause() {
  echo
  read -r -p "按回车回到菜单..."
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_deps() {
  cute_header
  echo "正在整理 Termux 环境。"
  echo "这一步会安装 git、nodejs-lts、python、curl、nano。"
  echo

  pkg update -y
  pkg upgrade -y
  pkg install -y git nodejs-lts python curl nano

  echo
  echo "依赖安装完成。"
}

install_st() {
  cute_header
  echo "准备安装 SillyTavern。"
  echo

  install_deps

  if [ -d "$ST_DIR/.git" ]; then
    cute_header
    echo "检测到 SillyTavern 已经存在："
    echo "$ST_DIR"
    echo
    echo "不重复安装。你可以选择菜单里的「更新酒馆」。"
    pause
    return
  fi

  if [ -d "$ST_DIR" ]; then
    cute_header
    echo "发现已有文件夹："
    echo "$ST_DIR"
    echo
    echo "但它不是 Git 仓库。"
    echo "为了避免误删你的文件，脚本不会覆盖它。"
    echo
    echo "你可以手动改名或删除这个文件夹后，再重新安装。"
    pause
    return
  fi

  cute_header
  echo "正在下载 SillyTavern release 分支..."
  echo

  git clone -b "$ST_BRANCH" "$ST_REPO" "$ST_DIR"

  cd "$ST_DIR"

  echo
  echo "正在安装 npm 依赖。"
  echo "这一步可能比较慢，手机不要锁死后台。"
  echo

  npm install

  cute_header
  echo "SillyTavern 安装完成。"
  echo
  echo "启动后请用浏览器打开："
  echo "http://127.0.0.1:$PORT"
  echo
  echo "也可以在菜单里选择「启动酒馆」。"
  pause
}

update_st() {
  cute_header

  if [ ! -d "$ST_DIR/.git" ]; then
    echo "没有找到 SillyTavern。"
    echo
    echo "请先选择「安装酒馆」。"
    pause
    return
  fi

  cd "$ST_DIR"

  echo "正在准备更新 SillyTavern。"
  echo

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "检测到你改过本地文件。"
    echo "我先帮你 stash 保存，免得更新时被覆盖。"
    echo
    git stash push -m "auto-backup-before-update-$(date +%Y%m%d-%H%M%S)"
  fi

  echo "正在切换到 $ST_BRANCH 分支..."
  git fetch origin
  git checkout "$ST_BRANCH"

  echo
  echo "正在拉取更新..."
  git pull --ff-only origin "$ST_BRANCH"

  echo
  echo "正在更新 npm 依赖..."
  npm install

  cute_header
  echo "SillyTavern 更新完成。"
  echo
  echo "可以回到菜单启动酒馆了。"
  pause
}

start_st() {
  cute_header

  if [ ! -d "$ST_DIR" ]; then
    echo "没有找到 SillyTavern。"
    echo
    echo "请先选择「安装酒馆」。"
    pause
    return
  fi

  cd "$ST_DIR"

  echo "准备启动 SillyTavern。"
  echo
  echo "浏览器打开："
  echo "http://127.0.0.1:$PORT"
  echo
  echo "Termux 不要关。"
  echo "想停止酒馆，就回到 Termux 按 Ctrl + C。"
  echo

  line

  termux-wake-lock 2>/dev/null || true
  node server.js
}

repair_npm() {
  cute_header

  if [ ! -d "$ST_DIR" ]; then
    echo "没有找到 SillyTavern。"
    echo
    echo "请先选择「安装酒馆」。"
    pause
    return
  fi

  cd "$ST_DIR"

  echo "准备修复 npm 依赖。"
  echo
  echo "这会删除 node_modules 和 package-lock.json，然后重新 npm install。"
  echo "如果你之前启动报奇怪的依赖错误，可以用这个。"
  echo

  read -r -p "确定要修复吗？输入 y 继续： " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo
    echo "已取消。"
    pause
    return
  fi

  rm -rf node_modules package-lock.json
  npm install

  cute_header
  echo "npm 依赖修复完成。"
  pause
}

update_menu_script() {
  cute_header
  echo "正在更新这个一键菜单脚本。"
  echo

  pkg install -y curl >/dev/null 2>&1 || true
  curl -fsSL "$MENU_URL" -o "$MENU_PATH"
  chmod +x "$MENU_PATH"

  cute_header
  echo "菜单脚本更新完成。"
  echo
  echo "重新打开 Termux，或者输入下面这句重新进入菜单："
  echo
  echo "bash ~/st-menu.sh"
  pause
}

enable_auto_start() {
  cute_header
  echo "正在设置：打开 Termux 自动进入酒馆菜单。"
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

  echo "已开启。"
  echo
  echo "以后打开 Termux 会自动进入菜单。"
  pause
}

disable_auto_start() {
  cute_header

  if [ -f "$BASHRC" ]; then
    sed -i "/$AUTO_MARK_START/,/$AUTO_MARK_END/d" "$BASHRC"
    echo "已关闭自动进入菜单。"
  else
    echo "没有找到 ~/.bashrc，不需要处理。"
  fi

  echo
  echo "以后想手动打开菜单，输入："
  echo
  echo "bash ~/st-menu.sh"
  pause
}

make_shortcut() {
  cute_header

  SHORTCUT_DIR="$HOME/.shortcuts"
  SHORTCUT_FILE="$SHORTCUT_DIR/启动酒馆"

  mkdir -p "$SHORTCUT_DIR"

  cat > "$SHORTCUT_FILE" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
cd "\$HOME/SillyTavern" || exit 1
termux-wake-lock 2>/dev/null || true
node server.js
EOF

  chmod +x "$SHORTCUT_FILE"

  echo "已生成 Termux:Widget 桌面快捷脚本："
  echo "$SHORTCUT_FILE"
  echo
  echo "如果你安装了 Termux:Widget，可以在桌面添加小组件。"
  echo "点一下「启动酒馆」就能启动 SillyTavern。"
  echo
  echo "没有装 Termux:Widget 也没关系，这一步不会影响正常使用。"
  pause
}

show_info() {
  cute_header

  echo "当前设置："
  line
  echo "SillyTavern 路径：$ST_DIR"
  echo "酒馆分支：$ST_BRANCH"
  echo "菜单脚本：$MENU_PATH"
  echo "默认端口：$PORT"
  echo "本机访问：http://127.0.0.1:$PORT"
  line
  echo
  echo "常见问题："
  echo
  echo "1. 浏览器打不开"
  echo "   先确认 Termux 里 node server.js 没有报错。"
  echo
  echo "2. 后台被杀"
  echo "   关闭省电限制，Termux 不要被系统清后台。"
  echo
  echo "3. npm install 很慢"
  echo "   正常。安卓跑这个就是有点磨人。"
  echo
  echo "4. 更新失败"
  echo "   可以先用「修复 npm 依赖」，再重试更新。"
  echo
  echo "5. 不想打开 Termux 自动进菜单"
  echo "   选菜单里的「关闭自动进入菜单」。"

  pause
}

uninstall_menu_only() {
  cute_header
  echo "这个功能只删除菜单脚本和自动启动设置。"
  echo "不会删除 SillyTavern 本体。"
  echo

  read -r -p "确定删除菜单吗？输入 y 继续： " confirm

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
  echo "菜单脚本已删除。"
  echo "SillyTavern 本体还在：$ST_DIR"
  pause
}

while true; do
  cute_header

  echo "今天想对小酒馆做什么？"
  echo
  echo "  1. 安装酒馆"
  echo "  2. 更新酒馆"
  echo "  3. 启动酒馆"
  echo "  4. 修复 npm 依赖"
  echo
  echo "  5. 更新这个菜单脚本"
  echo "  6. 开启 Termux 自动进入菜单"
  echo "  7. 关闭 Termux 自动进入菜单"
  echo "  8. 生成桌面快捷启动脚本"
  echo
  echo "  9. 查看说明"
  echo "  0. 退出菜单"
  echo
  line

  read -r -p "请选择： " choice

  case "$choice" in
    1) install_st ;;
    2) update_st ;;
    3) start_st ;;
    4) repair_npm ;;
    5) update_menu_script ;;
    6) enable_auto_start ;;
    7) disable_auto_start ;;
    8) make_shortcut ;;
    9) show_info ;;
    0)
      clear
      echo "已退出菜单。"
      echo
      echo "想重新打开菜单，输入："
      echo "bash ~/st-menu.sh"
      echo
      exit 0
      ;;
    *)
      echo
      echo "乱按什么，重新选。"
      sleep 1
      ;;
  esac
done
