#!/usr/bin/env bash

# The script needs to be run with sudo

let step_num=1

step() {
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "[Step $step_num]: $1"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    let step_num=$step_num+1
}

step "add ppa-repositories"
sudo add-apt-repository ppa:hluk/copyq -y && \
sudo apt-add-repository ppa:fish-shell/release-3 -y && \

# add ppa before this
step "apt update"
sudo apt update -y

# step "apt upgrade"
# sudo apt upgrade -y

step "install copyq"
sudo apt install copyq -y

step "install fish shell"
sudo apt-get install fish -y

step "install openssh-server"
sudo apt install openssh-server -y

step "install tmux, vim, guake"
sudo apt install tmux vim guake -y

step "install fisher"