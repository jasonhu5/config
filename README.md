# Ubuntu config

## Simple setup (fewer steps)
```
wget https://github.com/jasonhu5/config/archive/master.zip && \
unzip master.zip && \
rm master.zip && \
cd config-master
```

* To setup a headless device:
  ```
  sudo bash install.sh headless 2>&1 | tee /tmp/initial_setup.log
  ```
* To setup a desktop device (with more GUI applications):
  ```
  sudo bash install.sh desktop 2>&1 | tee /tmp/initial_setup.log
  ```

The setup script will print to screen and log the same contents to `/tmp/initial_setup.log`.

## Step by step

* .bashrc
* tmux
    ```
    mv .tmux ~ && mv .tmux.conf ~
    ```
  * [Add plugins](https://github.com/tmux-plugins/tpm)
    ```
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```
  * [Copy text selected](https://unix.stackexchange.com/questions/348913/copy-selection-to-a-clipboard-in-tmux)
    * install xclip first: `sudo apt update && sudo apt install -y xclip`
* inputrc
* vim
  * (maybe? a bit hard to configure this) [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe)
* guake terminal: `sudo apt-get install guake -y`

### Ubuntu adjust partition
* [use gparted](https://askubuntu.com/questions/66000/how-to-merge-partitions)
* remember to [update grub](https://askubuntu.com/questions/671788/how-to-increase-size-of-boot-partition-using-gparted) after partition change influencing boot drive
* [mount external disks](https://www.cyberciti.biz/faq/mount-drive-from-command-line-ubuntu-linux/)
* [backup folders](https://askubuntu.com/questions/302642/how-to-copy-a-directory-from-one-hard-drive-to-another-with-every-single-file)

### CopyQ
* ([Reference](https://hluk.github.io/CopyQ/))
    ```
    sudo add-apt-repository ppa:hluk/copyq -y && \
    sudo apt update -y && \
    sudo apt install copyq -y
    ```

### Fish
TODO: make this easier
1. install fish
    ```bash
    sudo apt-add-repository ppa:fish-shell/release-3 -y && \
    sudo apt-get update -y && \
    sudo apt-get install fish -y
    ```
    * Optional reference to make it the default shell: [here](https://fishshell.com/docs/current/tutorial.html#switching-to-fish)
1. Enter fish shell
    ```
    fish
    ```
1. config colors (web GUI)
    ```
    # configure the color, to e.g. Dracula
    fish_config
    ```
1. install fisher plugin manager ([ref](https://github.com/jorgebucaran/fisher))
    ```
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

    ```
1. install packages required by some plugins
    * fonts required for `tide` ([ref](https://github.com/IlanCosman/tide#fonts))
        * [MesloLGS NF Regular.ttf](https://github.com/IlanCosman/tide/blob/assets/fonts/mesloLGS_NF_regular.ttf?raw=true)
        * [MesloLGS NF Bold.ttf](https://github.com/IlanCosman/tide/blob/assets/fonts/mesloLGS_NF_bold.ttf?raw=true)
        * [MesloLGS NF Italic.ttf](https://github.com/IlanCosman/tide/blob/assets/fonts/mesloLGS_NF_italic.ttf?raw=true)
        * [MesloLGS NF Bold Italic.ttf](https://github.com/IlanCosman/tide/blob/assets/fonts/mesloLGS_NF_bold_italic.ttf?raw=true)
        * Also, set the terminal font to one of these
    * packages required by `PatrickF1/fzf` ([ref](https://github.com/PatrickF1/fzf.fish#installation))
        * In fish shell:
            ``` bash
            # fzf
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
            ~/.fzf/install && \
            # fd
            sudo apt install fd-find -y && \
            ln -s (which fdfind) ~/.local/bin/fd &&\
            # bat
            sudo apt install bat -y && \
            ln -s /usr/bin/batcat ~/.local/bin/bat
            ```
1. install plugins with `fisher`
    ```
    fisher install jorgebucaran/fisher && \
    # fisher install franciscolourenco/done && \  # seems problematic
    fisher install PatrickF1/fzf.fish && \
    fisher install IlanCosman/tide && \
    fisher install edc/bass    # using bash utilities in fish, check out https://github.com/edc/bass
    ```
1. move config folder to destined
    ```
    mkdir -p ~/.config/fish && \
    cp .config/fish/config.fish ~/.config/fish
    ```
1. NOTE: if fuzzy find is not working properly, make sure the versions of dependencies are met: [requirements](https://github.com/PatrickF1/fzf.fish#installation)

### Albert
* [DEB based manager](https://albertlauncher.github.io/docs/installing/)

### Git
* (should be deprecated, use SSH always) [Remember credentials](https://git-scm.com/docs/git-credential-store)

### TODO
* VSCode plugins
    * Ref [link](https://www.ubuntupit.com/best-visual-studio-code-extensions-for-programmers/)
* chrome extensions
