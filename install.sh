#!/data/data/com.termux/files/usr/bin/bash

set -e

GITHUB_USER="jimmyNIE-0901"
REPO_NAME="sillytavern-termux-installer"
BRANCH="main"

MENU_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/st-menu.sh"
MENU_PATH="$HOME/st-menu.sh"
BASHRC="$HOME/.bashrc"

AUTO_MARK_START="# >>> SillyTavern Menu Auto Start >>>"
AUTO_MARK_END="# <<< SillyTavern Menu Auto Start <<<"

clear
echo "╭────────────────────────────────────╮"
echo "│   SillyTavern 安卓小助手安装中      │"
echo "╰────────────────────────────────────╯"
echo
echo "正在准备 Termux 环境，先让小猫找一下工具箱..."
echo

pkg update -y
pkg install -y curl

echo
echo "正在下载菜单脚本..."
echo "来源：${MENU_URL}"
echo

curl -fsSL "$MENU_URL" -o "$MENU_PATH"
chmod +x "$MENU_PATH"

echo
echo "正在设置：以后打开 Termux 自动进入酒馆菜单..."
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

echo "╭────────────────────────────────────╮"
echo "│              安装完成              │"
echo "╰────────────────────────────────────╯"
echo
echo "以后打开 Termux，就会自动进入 SillyTavern 菜单。"
echo "如果不想自动进入，可以在菜单里选择关闭自动启动。"
echo
echo "现在马上带你进去。"
sleep 1

bash "$MENU_PATH"
