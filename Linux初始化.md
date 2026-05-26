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
mkdir Software Workspace
~~~

## 卸载 Snap

~~~bash
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

# 阻止 snapd 的安装
sudo nano /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
~~~

## 安装浏览器

~~~bash
# 安装 Firefox
## 创建一个目录以存储 APT 仓库密钥,如果不存在:
sudo install -d -m 0755 /etc/apt/keyrings
## 导入 Mozilla APT 仓库签名密钥:
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
## 如果你没有wget已安装,可安装
sudo apt-get install wget
## 指纹应该是 35BAA303E9EB3965F59CA838C0BA5CE6DC6315A3。您可以使用以下命令进行检查:
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
### 上面的我反正不匹配，不知道为啥，但是能用
## 接下来,将 Mozilla APT 仓库添加到您的 sources.list 中
## 适用于 Debian Trixie/Ubuntu Resolute 和 Newer：同时直接修改清华源
sudo tee /etc/apt/sources.list.d/mozilla.sources > /dev/null << EOF
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/mozilla/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF 
## 配置 APT 以优先处理来自 Mozilla 仓库的软件包:
sudo tee /etc/apt/preferences.d/mozilla > /dev/null << EOF
Package: *
Pin: release a=mozilla
Pin-Priority: 1001
EOF
## 更新您的包列表并安装
sudo apt-get update
sudo apt-get install firefox
## 安装中文语言包
sudo apt install -y firefox-l10n-zh-cn
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
# 找到 ls 添加 --group-directories-first
if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    conda activate "$CONDA_DEFAULT_ENV"
fi

# 开机默认关闭
conda config --set auto_activate false

# 修改源，也配置清华源
channels:
  - conda-forge
  - bioconda
auto_activate: false
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud

# 安装 mamba，2.6.1不好用，推荐2.5.0。等清华源和 mamba 更新大版本在用
conda install mamba=2.5.0
mamba update -a
~~~

## 安装输入法

~~~bash
sudo apt install fcitx5 \
fcitx5-chinese-addons \
fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 \
fcitx5-frontend-qt5 fcitx5-configtool
~~~

## ZoogVPN（UDP快）

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

## GitHub

~~~bash
# 安装 git
sudo apt install git-all

# 拉取最新代码
git pull origin main

# 查看哪些文件修改
git status

# 添加所有修改过的文件（最常用）
git add .

# 或只添加特定文件
git add 文件名1 文件名2

# 或添加整个目录
git add 目录名/

# 提交修改到本地仓库
git commit -m "清晰描述本次修改的内容"

# 推送到远程仓库
git push
~~~

