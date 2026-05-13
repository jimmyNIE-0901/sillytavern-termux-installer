# sillytavern-termux-installer
SillyTavern Termux one-click installer
# SillyTavern 安卓一键部署脚本

适用于 Termux 的 SillyTavern 一键安装 / 更新 / 启动菜单。

## 使用方式

在 Termux 里复制下面这一行：

```bash
pkg install -y curl && curl -fsSL https://raw.githubusercontent.com/jimmyNIE-0901/sillytavern-termux-installer/main/install.sh | bash
```

运行后会自动：

- 下载菜单脚本
- 设置打开 Termux 自动进入菜单
- 支持安装 SillyTavern
- 支持更新 SillyTavern
- 支持启动 SillyTavern
- 支持修复 npm 依赖
- 支持关闭自动进入菜单

## 启动地址

SillyTavern 启动后，在手机浏览器打开：

```text
http://127.0.0.1:8000
```

## 手动打开菜单

如果没有自动进入菜单，可以输入：

```bash
bash ~/st-menu.sh
```
