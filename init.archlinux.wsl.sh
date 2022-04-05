#!/bin/bash

# 修改pacman源为腾讯源，直接改/etc/pacman.conf而非/etc/pacman.d/mirrorlist，因为有时更新系统会覆盖后者
sudo sed -i '/^Include = /s/^.*$/Server = https:\/\/mirrors.tencent.com\/manjaro\/stable\/$repo\/$arch/' /etc/pacman.conf

# 添加腾讯云的archlinuxcn源
echo -e '[archlinuxcn]\nServer = https://mirrors.tencent.com/archlinuxcn/$arch' |
    sudo tee -a /etc/pacman.conf

# pacman配置彩色输出与使用系统日志
sudo sed -i "/^#Color$/s/#//; /^#UseSyslog$/s/#//; /^SigLevel/s/=.*$/= Never/;" /etc/pacman.conf

# 更新系统，并准备下载软件包
sudo pacman -Syyu
sudo pacman -S archlinuxcn-keyring yay expac base-devel

# 提供了git对github与gitee的ssh配置
if [[ "$USER" == beardad ]] ;then
    cp -v .gitconfig ~
    mkdir ~/.ssh
    cat ssh/config >> ~/.ssh/config
    #################################
    ## 然后安装我自己的ssh公私钥对 ##
    #################################
fi

# 配置tmux
yay -S tmux tmux-resurrect-git
cp -v tmux/tmux.conf ~/.tmux.conf

# 配置zsh
yay -S oh-my-zsh manjaro-zsh-config autojump
cp -v zsh/zshrc ~/.zshrc
chsh -s /bin/zsh

# 配置集成开发环境vim+cpp+go+python+js+bash
yay -S zip unzip \
    vim neovim python-pynvim neovim-plug \
    ripgrep silver-searcher-git global ctags \
    npm yarn php python-pip \
    vim-language-server vint \
    bash-language-server shellcheck \
    go \
    clang cmake cmake-language-server
git clone https://gitee.com/mrbeardad/SpaceVim ~/.SpaceVim
ln -sv ~/.SpaceVim/mode ~/.SpaceVim.d
mkdir ~/.config/
ln -sv ~/.SpaceVim ~/.config/nvim
mkdir ~/.local/bin
g++ -O3 -DNDEBUG -std=c++11 -o ~/.local/bin/quickrun_time ~/.SpaceVim/custom/quickrun_time.cpp
curl -Lo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > ~/.local/bin/win32yank.exe
chmod +x ~/.local/bin/win32yank.exe
cp -rv vscode/vscode-neovim/ ~/.vscode-neovim
cp -v vscode/.clang-format ~/

# 安装SeeCheatSheets
git clone https://gitee.com/mrbeardad/SeeCheatSheets ~/.cheat
(
    mkdir ~/.cheat/build
    cd ~/.cheat/build || exit 1
    cmake -D CMAKE_BUILD_TYPE=Release ..
    cmake --build . -t see
    cmake --install .
)

# 安装命令行工具
yay -S delve gdb conan graphviz cppcheck boost asio gtest gmock google-glog \
    tig openssh strace lsof socat nmap tcpdump gist daemonize docker nginx \
    man tree lsd fzf ranger htop bashtop iotop iftop dstat ncdu cloc \
    neofetch toilet cowfortune cmatrix sl asciiquarium
go env -w GOPATH="$HOME"/.local/go/
go env -w GOBIN="$HOME"/.local/bin/
go env -w GOPROXY=https://mirrors.tencent.com/go/
go get -u github.com/google/pprof
go get -u github.com/juntaki/gogtags
pip config set global.index-url https://mirrors.tencent.com/pypi/simple
pip install cppman thefuck mycli pylint flake8 bandit pudb ipython
npm config set registry http://mirrors.tencent.com/npm/
# htop配置
mkdir ~/.config/htop
cp -v htop/htoprc ~/.config/htop/htoprc
# gdb配置
cp -v gdb/gdbinit ~/.gdbinit

# docker配置
sudo mkdir /etc/docker
echo -e "{\n    \"registry-mirrors\": [\"http://hub-mirror.c.163.com\"]\n}" | sudo tee /etc/docker/daemon.json
sudo gpasswd -a "$USER" docker
sudo daemonize /bin/dockerd
sudo docker pull mysql
sudo docker pull redis

# GUI工具配置
cp -v ./xdg-open ~/.local/bin