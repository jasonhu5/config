# Ubuntu config

* bash
* tmux
  * [Add plugins](https://github.com/tmux-plugins/tpm)
  * [Copy text selected](https://unix.stackexchange.com/questions/348913/copy-selection-to-a-clipboard-in-tmux)
    * install xclip first: `sudo apt update && sudo apt install -y xclip`
* inputrc
* vim
* guake terminal: `sudo apt-get install guake -y`

### Ubuntu adjust partition
* [use gparted](https://askubuntu.com/questions/66000/how-to-merge-partitions)
* remember to [update grub](https://askubuntu.com/questions/671788/how-to-increase-size-of-boot-partition-using-gparted) after partition change influencing boot drive
* [mount external disks](https://www.cyberciti.biz/faq/mount-drive-from-command-line-ubuntu-linux/)
* [backup folders](https://askubuntu.com/questions/302642/how-to-copy-a-directory-from-one-hard-drive-to-another-with-every-single-file)

### Git
* [Remember credentials](https://git-scm.com/docs/git-credential-store)

### CopyQ
* [Better install with PPA](https://hluk.github.io/CopyQ/)

### Albert
* [DEB based manager](https://albertlauncher.github.io/docs/installing/)

### Fish
1. install fish
    ```
    sudo apt-add-repository ppa:fish-shell/release-3
    sudo apt-get update
    sudo apt-get install fish
    ```
2. move config folder to destined
    ```
    mkdir -p ~/.config
    mv [PATH_TO/REPO]/.config/fish ~/.config
    ```
3. ref `fisher` plugins, see next point for dependency installation
    ```
    jorgebucaran/fisher
    IlanCosman/tide
    franciscolourenco/done
    PatrickF1/fzf.fish
    ```
4. install packages required by some plugins
  * fonts required for `tide`: [here](https://github.com/IlanCosman/tide#fonts)
  * packages required by `fzf`: [here](https://github.com/PatrickF1/fzf.fish#installation)
    * **NOTICE**: make symbolic links if necessary for `fd` (see [this](https://github.com/PatrickF1/fzf.fish/discussions/93)) and `bat` ([this](https://github.com/sharkdp/bat#on-ubuntu-using-apt))



### TODO
* VSCode plugins
    * Ref [link](https://www.ubuntupit.com/best-visual-studio-code-extensions-for-programmers/)
* chrome extensions
