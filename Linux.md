## 修改中文目录

~~~bash
# 安装 vim，默认兼容版（难用）
vi ~/.config/user-dirs.dirs

# 原路径
XDG_DESKTOP_DIR="$HOME/桌面"
XDG_DOWNLOAD_DIR="$HOME/下载"
XDG_TEMPLATES_DIR="$HOME/模板"
XDG_PUBLICSHARE_DIR="$HOME/公共的"
XDG_DOCUMENTS_DIR="$HOME/文档"
XDG_MUSIC_DIR="$HOME/音乐"
XDG_PICTURES_DIR="$HOME/图片"
XDG_VIDEOS_DIR="$HOME/视频"
# 新路径
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"

# 改名
cd ~
mv 桌面 Desktop
mv 下载 Downloads
mv 模板 Templates
mv 公共 Public
mv 文档 Documents
mv 音乐 Music
mv 图片 Pictures
mv 视频 Videos
~~~

## 卸载 Snap

~~~bash
# 安装 chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

snap list
sudo snap remove --purge # all

sudo apt purge snapd -y
sudo apt update

rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/cache/snapd

sudo umount /snap 2>/dev/null
sudo rmdir /snap 2>/dev/null

sudo nano /etc/apt/preferences.d/nosnap.pref
# 阻止 snapd 的安装
Package: snapd
Pin: release a=*
Pin-Priority: -10
~~~

## 安装 conda

~~~bash
# 换源，可换清华源
less /etc/apt/sources.list.d/ubuntu.sources

# 此命令会将官方源替换为清华源
sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources
sudo sed -i 's|http://security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt update

# 添加到 ~/.bashrc
alias le="less -S"
alias hu="htop -u"
alias ct="column -t"
alias se="source ~/miniconda3/bin/activate"
alias cae="conda activate"
alias ntb="nohup time bash"
alias lh="ll -ahl"
alias ls="ls --group-directories-first"
if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    conda activate "$CONDA_DEFAULT_ENV"
fi

# 开机默认关闭
conda config --set auto_activate false

# 修改源
- conda-forge
- bioconda

# 安装 mamba
conda install mamba
mamba update -a
~~~

## 安装输入法

~~~bash
sudo apt install fcitx5 \
fcitx5-chinese-addons \
fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 \
fcitx5-frontend-qt5 fcitx5-configtool
~~~

## 配置 ZoogVPN（UDP快）

~~~bash
# 下载压缩包，找张雪杰要

# 提取 ca.zoogvpn.com.crt 证书
## 编辑任意一个 .opvn 提取 <ca> 和 </ca> 这两个标签间的内容，不包括这两个标签，放入 ca.zoogvpn.com.crt 文件

# 网络配置里 VPN 点 +，从文件导入，然后设置密码邮箱证书

# 重置网络（应该是）
sudo systemctl restart systemd-resolved
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# 连接一会断连，ipv6 的问题
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
# 重新连接，若成功，则永久禁用 ipv6
sudo nano /etc/sysctl.conf
# 添加
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
# 然后
sudo sysctl -p
~~~

