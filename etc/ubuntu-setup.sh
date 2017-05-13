#!/bin/bash

COLOR_NONE="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_WHITE="\033[1;37m"


_version_check() {
    curver="$1"; targetver="$2";
    [ "$targetver" = "$(echo -e "$curver\n$targetver" | sort -V | head -n1)" ]
}

install_essential_packages() {
    local -a packages; packages=( \
        build-essential \
        vim zsh curl \
        python-software-properties software-properties-common \
        cmake cmake-data ctags autoconf pkg-config \
        terminator htop iotop iftop \
        silversearcher-ag \
        openssh-server mosh rdate \
        )

    sudo apt-get install -y ${packages[@]}
}

install_ppa_git() {
    # https://launchpad.net/~git-core/+archive/ubuntu/ppa
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get install -y git-all git-extras
}

install_ppa_vim8() {
    # For Ubuntu 14.04 and 16.04
    # https://launchpad.net/~jonathonf/+archive/ubuntu/vim
    sudo add-apt-repository -y ppa:jonathonf/vim
    sudo apt-get update
    sudo apt-get install -y vim vim-doc vim-nox
    #sudo apt-get install -y vim-gnome vim-gtk
}

install_neovim() {
    # https://launchpad.net/~neovim-ppa/+archive/ubuntu/unstable
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim

    command -v /usr/bin/pip 2>&1 > /dev/null || sudo apt-get install -y python-pip
    command -v /usr/bin/pip3 2>&1 > /dev/null || sudo apt-get install -y python3-pip
    sudo /usr/bin/pip install --upgrade neovim
    sudo /usr/bin/pip3 install --upgrade neovim
}

install_latest_tmux() {
    # tmux 2.3 is installed from source compilation,
    # as there is no tmux 2.3+ package that is compatible with ubuntu 14.04
    # For {libncurses,libevent >= 6}, we might use
    # https://launchpad.net/ubuntu/+archive/primary/+files/tmux_2.3-4_${archi}.deb
    # archi=$(dpkg --print-architecture)  # e.g. amd64
    set -e

    if _version_check "$(tmux -V | cut -d' ' -f2)" "2.3"; then
        echo "$(tmux -V) : $(which tmux)"
        echo "  Already installed, skipping installation"; return
    fi
    apt-get install -y libevent-dev libncurses5-dev libutempter-dev || exit 1;
    TMP_TMUX_DIR="/tmp/.tmux-src/"

    TMUX_TGZ_FILE="tmux-2.3.tar.gz"
    TMUX_DOWNLOAD_URL="https://github.com/tmux/tmux/releases/download/2.3/${TMUX_TGZ_FILE}"

    wget -nc ${TMUX_DOWNLOAD_URL} -P ${TMP_TMUX_DIR} || exit 1;
    cd ${TMP_TMUX_DIR} && tar -xvzf ${TMUX_TGZ_FILE} || exit 1;
    cd "tmux-2.3" && ./configure || exit 1;
    make clean && make -j2 && make install || exit 1;
    tmux -V
}

install_ppa_nginx() {
    # https://launchpad.net/~nginx/+archive/ubuntu/stable
    sudo add-apt-repository -y ppa:nginx/stable
    sudo apt-get update
    sudo apt-get install -y nginx
}

install_node() {
    # https://github.com/nodesource/distributions/tree/master/deb
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs

    # some default global packages
    sudo npm install -g http-server
}

install_exa() {
    # https://github.com/ogham/exa/releases
    if _version_check "$(exa --version | cut -d' ' -f2)" "0.4.0"; then
        echo "$(exa --version) : $(which exa)"
        echo "  Already installed, skipping installation"; return
    fi

    echo -e "${COLOR_WHITE}Downloading exa...${COLOR_NONE}"
    EXA_DOWNLOAD_URL="https://github.com/ogham/exa/releases/download/v0.4.0/exa-linux-x86_64.zip"
    EXA_BINARY_SHA1SUM="822ea64b390071298866ce84546811f57eb8503c"  # exa-linux-x86_64 v0.4.0
    TMP_EXA_DIR="/tmp/exa/"

    wget -nc ${EXA_DOWNLOAD_URL} -P ${TMP_EXA_DIR} || exit 1;
    cd ${TMP_EXA_DIR} && unzip -o "exa-linux-x86_64.zip" || exit 1;
    if [[ "$EXA_BINARY_SHA1SUM" != "$(sha1sum exa-linux-x86_64 | cut -d' ' -f1)" ]]; then
        echo -e "${COLOR_RED}SHA1 checksum mismatch, aborting!${COLOR_NONE}"
        exit 1;
    fi
    sudo cp "exa-linux-x86_64" "/usr/local/bin/exa" || exit 1;
    echo -e "${COLOR_GREEN}Installation of exa successful!${COLOR_NONE}"
    echo "$(which exa) : $(exa --version)"
    rm -rf ${TMP_EXA_DIR}
}

install_all() {
    # TODO dependency management: duplicated 'apt-get update'?
    install_essential_packages
    install_node
    install_latest_tmux
    install_ppa_vim8
    install_neovim
    install_ppa_git
    install_ppa_nginx
    install_exa
}


# entrypoint script
if [ `uname` != "Linux" ]; then
    echo "Run on Linux (not on Mac OS X)"; exit 1
fi
if [ -n "$1" ]; then
    $1
else
    echo "Usage: $0 [command], where command is one of the following:"
    declare -F | cut -d" " -f3 | grep -v '^_'
fi
