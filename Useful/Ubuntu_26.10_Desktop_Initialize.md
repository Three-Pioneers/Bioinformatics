# Ubuntu 26.10 笔记本日常使用初始化

适用设备：戴尔灵越 7572，16 GB 内存，NVIDIA GeForce MX150。

用途：日常上网、办公、蓝牙设备，以及使用向日葵控制其他电脑。

方案：安装 Firefox DEB 版；备份后移除全部 Snap 应用和 snapd；移除不用的打印、指纹和蜂窝网络组件；保留蓝牙、声音、电源管理、固件更新及安全更新；通过 Ubuntu 安装显卡驱动。

整理日期：2026-11-14。本文件是独立的新文档，不修改原来的 Linux_Initialize.md。

## 使用方法

- 在目标 Ubuntu 26.10 的 Bash 终端中，按章节顺序、分段运行代码。不要在 Windows PowerShell 中执行。
- 使用普通用户运行，不要先执行 sudo -i；需要管理员权限的命令已经包含 sudo。
- 某段报错时，先解决错误，再继续下一段。不要将整篇 Markdown 当成脚本执行。
- 开始 Firefox 迁移和 Snap 卸载前，完全退出 Firefox 及其他 Snap 应用。
- 本方案针对普通 Ubuntu Desktop 安装。安装器提供的 TPM 硬件支持磁盘加密方案依赖系统 Snap，不能强行移除 snapd。卸载段会保守检查安装类型。
- Snap 段会移除全部 Snap 应用，包括 Snap 版应用中心和固件更新图形界面；GNOME Software 和 fwupd 分别提供替代的软件管理界面和固件更新后端。

以下命令没有在你的 Ubuntu 实机上执行；Bash 语法检查不能替代显卡、蓝牙、休眠和远程控制的实机验证。

## 1. 检查版本、更新系统并安装基础工具

~~~bash
(
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
    echo "请使用普通用户运行，不要使用 sudo -i。"
    exit 1
fi

. /etc/os-release

if [[ "$ID" != "ubuntu" || "$VERSION_ID" != "26.10" ]]; then
    printf '本文件针对 Ubuntu 26.10；当前系统：%s\n' "$PRETTY_NAME"
    exit 1
fi

sudo apt update
sudo apt upgrade

sudo apt install ca-certificates curl gnupg ubuntu-drivers-common software-properties-gtk fwupd
)
~~~

上面全部成功后，保存工作并重启。后续操作在重启后继续：

~~~bash
sudo reboot
~~~

## 2. 安装 Firefox DEB 版并迁移配置

这里使用 Mozilla 官方仓库。仓库的 Suites 保持 mozilla，不要改成 Ubuntu 的系统代号。

如果原来使用 Snap Firefox，本段会先将其配置备份到主目录下的 firefox-backup.* 文件夹，再迁移到 DEB 版使用的位置。已有的 DEB 配置也会保存到备份目录。

~~~bash
(
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
    echo "请使用普通用户运行。"
    exit 1
fi

if pgrep -u "$(id -u)" -x 'firefox|firefox-bin' >/dev/null; then
    echo "请先完全退出 Firefox，再运行本段。"
    exit 1
fi

# 下载并验证 Mozilla 仓库密钥
mozilla_key="$(mktemp)"
trap 'rm -f -- "$mozilla_key"' EXIT

curl --fail --show-error --location \
    https://packages.mozilla.org/apt/repo-signing-key.gpg \
    --output "$mozilla_key"

fingerprint="$(
    gpg --batch --show-keys --with-colons "$mozilla_key" |
    awk -F: '$1 == "fpr" && !found { print $10; found=1 }'
)"

if [[ "$fingerprint" != "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3" ]]; then
    echo "Mozilla 密钥指纹不匹配，停止安装。"
    printf '实际指纹：%s\n' "$fingerprint"
    exit 1
fi

# 在更换 Firefox 软件包前，先备份原配置
snap_profile="$HOME/snap/firefox/common/.mozilla/firefox"
profile_backup=""

if [[ -d "$snap_profile" ]]; then
    profile_backup="$(mktemp -d "$HOME/firefox-backup.XXXXXXXX")"
    cp -a -- "$snap_profile" "$profile_backup/firefox-snap"
    printf 'Firefox 配置备份：%s\n' "$profile_backup"
fi

sudo install -d -m 0755 /etc/apt/keyrings
sudo install -m 0644 "$mozilla_key" /etc/apt/keyrings/packages.mozilla.org.asc

sudo tee /etc/apt/sources.list.d/mozilla.sources >/dev/null <<'EOF'
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF

# 优先使用 Mozilla DEB，禁止 Ubuntu 的 Firefox Snap 过渡包
sudo tee /etc/apt/preferences.d/mozilla >/dev/null <<'EOF'
Package: firefox firefox-*
Pin: origin packages.mozilla.org
Pin-Priority: 1001

Package: firefox
Pin: release o=Ubuntu
Pin-Priority: -1
EOF

sudo apt update
sudo apt install firefox firefox-l10n-zh-cn

# 迁移备份中的原 Snap Firefox 配置
if [[ -n "$profile_backup" ]]; then
    mkdir -p "$HOME/.mozilla"

    if [[ -e "$HOME/.mozilla/firefox" ]]; then
        mv -- "$HOME/.mozilla/firefox" "$profile_backup/firefox-deb-before"
    fi

    cp -a -- "$profile_backup/firefox-snap" "$HOME/.mozilla/firefox"
fi

/usr/bin/firefox --version
)
~~~

首次启动配置选择器，选择原来的配置，确认书签、历史记录和需要的登录信息正常：

~~~bash
/usr/bin/firefox -P
~~~

如果是全新安装，没有旧数据，使用新配置即可。确认完成后，关闭 Firefox，再继续卸载 Snap。

## 3. 备份数据并卸载全部 Snap 和 snapd

本段只自动处理 generic-classic 普通安装。遇到其他模型或无法读取模型时会停止；这不代表所有其他模型都不能卸载，而是需要另行确认系统依赖。

快照备份导出到主目录下的 snap-backup.* 文件夹，不会随着 snapd 一起清除。快照不等于整机备份，应用目录之外的文件不在此备份范围内。

~~~bash
(
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
    echo "请使用普通用户运行。"
    exit 1
fi

if pgrep -u "$(id -u)" -x 'firefox|firefox-bin' >/dev/null; then
    echo "请先完全退出 Firefox。"
    exit 1
fi

# 确认 Firefox 已安装且不是 Snap 过渡包
firefox_status="$(dpkg-query -W -f='${Status}' firefox)"
firefox_version="$(dpkg-query -W -f='${Version}' firefox)"

if [[ "$firefox_status" != "install ok installed" || "$firefox_version" == *snap* ]]; then
    echo "请先完成 Firefox DEB 安装和数据验证。"
    exit 1
fi

# 根据软件包状态决定是否卸载，不能因 snap 命令缺失而跳过检查
snapd_state="$(dpkg-query -W -f='${db:Status-Status}' snapd 2>/dev/null || true)"

case "$snapd_state" in
    installed)
        if ! command -v snap >/dev/null 2>&1; then
            echo "snapd 包仍已安装，但 snap 命令缺失；停止操作。"
            exit 1
        fi
        ;;
    ""|not-installed|config-files)
        ;;
    *)
        printf 'snapd 软件包状态异常：%s；停止操作。\n' "$snapd_state"
        exit 1
        ;;
esac

if [[ "$snapd_state" == "installed" ]]; then
    # 读取失败时立即停止，不将报错当作普通安装
    snap_model="$(LC_ALL=C snap model --assertion)"

    if ! grep -Eq \
        '^model:[[:space:]]+generic-classic[[:space:]]*$' \
        <<<"$snap_model"; then
        echo "未确认是普通 generic-classic 安装，停止卸载。"
        echo "不要绕过检查；需先确认是否依赖系统 Snap 或 TPM 加密。"
        exit 1
    fi

    # 提前检查 snapd 卸载是否会连带移除核心桌面组件
    purge_plan="$(sudo env LC_ALL=C apt-get -s purge snapd)"
    printf '%s\n' "$purge_plan"

    if grep -Eq \
        '^(Remv|Purg) (ubuntu-desktop|ubuntu-desktop-minimal|ubuntu-session|gdm3|gnome-shell|network-manager|systemd|upower|power-profiles-daemon|fwupd|bluez)(:|[[:space:]])' \
        <<<"$purge_plan"; then
        echo "检测到核心桌面组件将被连带删除，停止操作。"
        exit 1
    fi

    snap_listing="$(LC_ALL=C snap list)"
    printf '%s\n' "$snap_listing"

    mapfile -t installed_snaps < <(
        awk 'NR > 1 {print $1}' <<<"$snap_listing"
    )

    if (( ${#installed_snaps[@]} > 0 )); then
        snap_backup="$(mktemp -d "$HOME/snap-backup.XXXXXXXX")"
        printf '%s\n' "$snap_listing" >"$snap_backup/installed-snaps.txt"

        # 创建快照，并导出所有已有快照
        sudo snap save

        saved_snapshots="$(LC_ALL=C snap saved)"
        mapfile -t snapshot_ids < <(
            awk '$1 ~ /^[0-9]+$/ {print $1}' <<<"$saved_snapshots" |
            sort -nu
        )

        if (( ${#snapshot_ids[@]} == 0 )); then
            echo "没有找到可导出的快照，停止卸载。"
            exit 1
        fi

        for snapshot_id in "${snapshot_ids[@]}"; do
            snapshot_file="$snap_backup/snapshot-$snapshot_id.snapbackup"
            sudo snap export-snapshot "$snapshot_id" "$snapshot_file"
            sudo chown "$(id -u):$(id -g)" "$snapshot_file"
            chmod 600 "$snapshot_file"
        done

        printf 'Snap 数据备份：%s\n' "$snap_backup"
    fi

    # 多轮移除，处理应用、内容包和基础 Snap 的依赖顺序
    while true; do
        snap_listing="$(LC_ALL=C snap list)"

        mapfile -t remaining_snaps < <(
            awk 'NR > 1 && $1 != "snapd" {print $1}' <<<"$snap_listing"
        )

        if (( ${#remaining_snaps[@]} == 0 )); then
            break
        fi

        removed_count=0

        for snap_name in "${remaining_snaps[@]}"; do
            if sudo snap remove --purge "$snap_name"; then
                removed_count=$((removed_count + 1))
            fi
        done

        if (( removed_count == 0 )); then
            echo "剩余 Snap 无法正常移除，停止；请检查上方错误。"
            exit 1
        fi
    done

    # 最后移除 snapd 自身的 Snap 包（如果存在）
    if awk 'NR > 1 && $1 == "snapd" {found=1}
            END {exit !found}' <<<"$snap_listing"; then
        sudo snap remove --purge snapd
    fi

    # 仅在前面的模型检查和 Snap 卸载全部成功后移除已安装的软件包
    sudo apt purge snapd
elif [[ "$snapd_state" == "config-files" ]]; then
    # 软件包已卸载，只清理包管理器记录的残留配置
    sudo apt purge snapd
fi

# 禁止 APT 再次安装 snapd
sudo tee /etc/apt/preferences.d/nosnap.pref >/dev/null <<'EOF'
Package: snapd
Pin: version *
Pin-Priority: -10
EOF

sudo apt update

# 安装 DEB 版图形软件管理器，不额外安装推荐的插件
sudo apt install --no-install-recommends gnome-software

echo "Snap 卸载完成。请保留 firefox-backup.* 和 snap-backup.* 备份。"
)
~~~

部分基础 Snap 可能暂时报“仍被其他 Snap 使用”，后续轮次会重试。整轮没有成功删除任何包时会停止。

不需要额外手动强删 /snap、/var/lib/snapd 或清空 ~/snap。残留用户目录不是仍在运行的 Snap 服务。

## 4. 移除不用的打印、指纹和蜂窝网络组件

你不使用打印机和指纹，因此移除对应组件。本段还假设不使用内置或 USB 4G/5G 调制解调器；如果需要此类设备，从候选列表中删去 modemmanager。

bluez-cups 仅用于蓝牙打印，移除它不会移除保留的 bluez 蓝牙功能。保留蓝牙音频组件。

~~~bash
(
set -euo pipefail

remove_packages=()

for package in \
    cups cups-daemon cups-browsed bluez-cups \
    fprintd libpam-fprintd \
    modemmanager
do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
       grep -qx 'install ok installed'; then
        remove_packages+=("$package")
    fi
done

if (( ${#remove_packages[@]} > 0 )); then
    removal_plan="$(sudo env LC_ALL=C apt-get -s purge "${remove_packages[@]}")"
    printf '%s\n' "$removal_plan"

    if grep -Eq \
        '^(Remv|Purg) (ubuntu-desktop|ubuntu-desktop-minimal|ubuntu-session|gdm3|gnome-shell|network-manager|systemd|upower|power-profiles-daemon|fwupd|bluez)(:|[[:space:]])' \
        <<<"$removal_plan"; then
        echo "检测到核心桌面组件将被连带删除，停止操作。"
        exit 1
    fi

    sudo apt purge "${remove_packages[@]}"
fi

sudo apt install bluez libspa-0.2-bluetooth
sudo systemctl enable --now bluetooth.service
)
~~~

不执行自动 autoremove。NetworkManager、声音、电源管理、fwupd、AppArmor、安全更新、图形桌面和休眠相关组件继续保留。

GNOME 自带远程桌面保持默认关闭即可。你通过向日葵控制其他电脑，不需要打开本机 GNOME 远程桌面服务。

## 5. 使用 Ubuntu 安装 MX150 显卡驱动

MX150 使用与它兼容的 NVIDIA 专有驱动，预期为 580 系列，不能选择 580-open。Ubuntu 26.10 仓库提供 nvidia-driver-580；让 Ubuntu 根据硬件自动匹配，无需添加显卡 PPA、安装 CUDA 或使用 NVIDIA 官网的 .run 安装器。

~~~bash
(
set -euo pipefail

sudo ubuntu-drivers list
sudo ubuntu-drivers install
)
~~~

如果安装过程中要求设置 MOK 密码，请记住它；重启出现密钥登记界面时选择 Enroll MOK，按提示完成。没有提示则无需进行此操作，也不必预先关闭 Secure Boot。

安装成功后，保存工作并重启：

~~~bash
sudo reboot
~~~

重启后检查：

~~~bash
nvidia-smi
~~~

正常显示 GeForce MX150 和驱动版本，说明 NVIDIA 驱动已加载。混合显卡笔记本的日常桌面仍由 Intel 核显渲染也可能是正常状态，不需要为了确认安装成功而强制全局使用独显。

## 6. 安装向日葵图形版

打开官方下载页，下载 Ubuntu / Deepin 对应的图形版、x86_64 / amd64 DEB 包。不要下载不能发起远控的命令行版。

~~~bash
xdg-open 'https://sunlogin.oray.com/download/linux/'
~~~

下载完成后执行下列代码。下载目录中应只有一个名称包含 sunlogin 的待安装 DEB 包；如果有多个版本，先把不准备安装的版本移到其他目录。

~~~bash
(
set -euo pipefail

download_dir="$(xdg-user-dir DOWNLOAD)"

if [[ ! -d "$download_dir" ]]; then
    echo "无法找到下载目录。"
    exit 1
fi

mapfile -d '' -t sunlogin_packages < <(
    find "$download_dir" -maxdepth 1 -type f \
        -iname '*sunlogin*.deb' -print0
)

if (( ${#sunlogin_packages[@]} != 1 )); then
    echo "请让下载目录中只保留一个待安装的向日葵 DEB 包，再重试。"
    exit 1
fi

sudo apt install "${sunlogin_packages[0]}"
)
~~~

从应用菜单启动向日葵，登录并连接目标电脑，测试画面、键盘、中文输入和剪贴板。

## 7. 最后检查

以下检查命令按需分别运行：

~~~bash
# 显卡驱动
nvidia-smi

# 蓝牙服务应显示 active
systemctl is-active bluetooth.service

# Firefox 应来自 Mozilla 仓库；snapd 版本优先级应为负数
apt-cache policy firefox snapd

# 清除当前终端的命令路径缓存，再检查 snap 命令
hash -r
if command -v snap >/dev/null 2>&1; then
    echo "仍存在 snap 命令，需要检查。"
else
    echo "snap 命令已移除。"
fi

# 查看系统服务失败项；输出不等于一定由本次操作导致
systemctl --failed --no-pager
~~~

再实际测试一次 Wi-Fi、蓝牙设备、声音、合盖唤醒和向日葵连接。中文输入法沿用系统原配置即可。

Ubuntu 26.10 为中间版本，支持期到 2027 年 7 月，需要在支持期内安排系统升级。

## 官方参考

- [Ubuntu 26.10 发布说明](https://documentation.ubuntu.com/release-notes/26.10/)
- [Mozilla：Linux 安装 Firefox 与数据迁移](https://support.mozilla.org/en-US/kb/install-firefox-linux)
- [Snap：卸载与系统类型限制](https://snapcraft.io/docs/explanation/security/decommissioning/)
- [Snap：创建及导出数据快照](https://snapcraft.io/docs/how-to-guides/manage-snaps/create-data-snapshots/)
- [Ubuntu：安装 NVIDIA 驱动](https://ubuntu.com/desktop/docs/en/latest/how-to/graphics/install-nvidia-drivers/)
- [Ubuntu 26.10：nvidia-driver-580 软件包](https://packages.ubuntu.com/stonking/nvidia-driver-580)
- [NVIDIA 580：支持的显卡列表](https://download.nvidia.com/XFree86/Linux-x86_64/580.119.02/README/supportedchips.html)
- [Ubuntu：Secure Boot](https://documentation.ubuntu.com/security/security-features/platform-protections/secure-boot/)
- [向日葵 Linux 官方下载](https://sunlogin.oray.com/download/linux/)
