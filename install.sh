#!/usr/bin/env bash

# The script needs to be run with sudo

##########################################
# globals
(( step_num=0 ))
step_msg=""
(( sub_step_num=1 ))
desktop=false
user_name=""


##########################################
# functions
step() {
  # print step number and info
  (( step_num++ ))
  step_msg="$1"
  echo
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo "[Step $step_num]: $step_msg"
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  (( sub_step_num=1))
}

sub_step() {
  # print step.sub_step number and info
  echo
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo "[Step $step_num.$sub_step_num]: ($step_msg) $1"
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  (( sub_step_num++ ))
}

disp_usage() {
  # display script usage
  echo "Usage: sudo bash install.sh \$USER headless|desktop"
  echo "  - headless: no GUI applications needed, e.g. guake, copyq"
  echo "  - desktop: GUI applications installed, too"
}


##########################################
# check for valid usage
if [ "$#" -ne 2 ] || [ "$2" != "headless" ] && [ "$2" != "desktop" ]; then
  # invalid usage
  disp_usage
  # Ref exit codes: https://www.cyberciti.biz/faq/linux-bash-exit-status-set-exit-statusin-bash/
  exit 22  # invalid argument
elif [ "$EUID" -ne 0 ]; then
  disp_usage
  exit 1  # operation not permitted
elif [ ! -d "/home/$1" ]; then
  # first argument should be the username
  disp_usage
  exit 22
else
  if [ "$2" = "desktop" ]; then
    desktop=true
  fi
  user_name=$1
  # verify flag set correctly
  if $desktop; then
    echo ">>> Starting setup for a Desktop device"
  else
    echo ">>> Starting setup for a Headless device"
  fi
  echo
fi


##########################################
step "add ppa-repositories"

sub_step "fish"
sudo apt-add-repository -y --no-update ppa:fish-shell/release-3

if $desktop; then
  sub_step "copyq"
  sudo add-apt-repository -y --no-update ppa:hluk/copyq
fi


# add ppa before this
##########################################
step "apt update"
sudo apt update -y


##########################################
# step "apt upgrade"
# sudo apt upgrade -y


##########################################
step "install with added ppa"

sub_step "fish"
sudo apt install -y fish

if $desktop; then
  sub_step "copyq"
  sudo apt install -y \
    copyq
fi


##########################################
step "install apt packages"

sub_step "openssh-server"
sudo apt install -y openssh-server

sub_step "tmux"
sudo apt install -y tmux

sub_step "vim"
sudo apt install -y vim

sub_step "git git-lfs"
sudo apt install -y git git-lfs

sub_step "python3 venv"
sudo apt install -y python3-venv

if $desktop; then
  sub_step "guake"
  sudo apt install -y guake
fi


##########################################
#step "apt autoremove"
#sudo apt autoremove -y


##########################################
step "Install Docker via convenience script"
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh


# Note: when moving files, the user matters
##########################################
step "config files"

user_home_dir="/home/$user_name"
sub_step ".inputrc"
mv .inputrc "$user_home_dir"

sub_step "vim"
mv .vimrc "$user_home_dir"
mv .vim "$user_home_dir"

sub_step "tmux"
mv .tmux.conf "$user_home_dir"
mv .tmux "$user_home_dir"
# tmux plugins
git clone https://github.com/tmux-plugins/tpm "$user_home_dir/.tmux/plugins/tpm"

# sub_step "fish"
# mkdir -p ~/.config/fish && \
# cp .config/fish/config.fish ~/.config/fish


##########################################
exit 0
