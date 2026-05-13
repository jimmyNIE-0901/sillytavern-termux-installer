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

echo "正在准备 Termux 环境..."
pkg update -y
pkg install -y curl

echo "正在下载 SillyTavern 菜单脚本..."
curl -fsSL "$MENU_URL" -o "$MENU_PATH"

chmod +x "$MENU_PATH"

echo "正在设置打开 Termux 自动进入脚本页面..."

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

echo
echo "安装完成。"
echo "以后打开 Termux 会自动进入 SillyTavern 菜单。"
echo
echo "现在立即启动菜单..."
sleep 1

bash "$MENU_PATH"
