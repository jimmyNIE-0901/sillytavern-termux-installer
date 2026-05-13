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

cat <<'EOF'
╭────────────────────────────────────╮
│                                    │
│      SillyTavern 安卓小窝安装器      │
│                                    │
│        一键部署 / 自动菜单 / 懒人版   │
│                                    │
╰────────────────────────────────────╯
EOF

echo
echo "正在准备 Termux 环境..."
echo "第一次运行可能会慢一点，别急着关。"
echo

pkg update -y
pkg install -y curl

echo
echo "正在下载菜单脚本..."
curl -fsSL "$MENU_URL" -o "$MENU_PATH"

chmod +x "$MENU_PATH"

echo
echo "正在设置：打开 Termux 自动进入酒馆菜单..."

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
cat <<'EOF'
╭────────────────────────────────────╮
│            安装器设置完成            │
╰────────────────────────────────────╯
EOF

echo
echo "以后打开 Termux，会自动进入 SillyTavern 菜单。"
echo "现在帮你打开菜单。"
echo

sleep 1
bash "$MENU_PATH"
