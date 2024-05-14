#!/usr/bin/env bash

# https://raw.githubusercontent.com/ChristmasZCY/Mbaysalt/master/install.sh
# curl -s 'https://raw.githubusercontent.com/ChristmasZCY/Mbaysalt/master/install.sh' | bash -s new

url0='https://github.com/ChristmasZCY/Mbaysalt.git'
branch0='master'

opt=$1

Usage() {
    echo "Usage: $0 [all|new]"
    exit 1
}



if [ "$1" == "all" ]; then
    echo "git clone all..."
    git clone --branch $branch0 $url0
elif [ "$1" == "new" ]; then
    echo "git clone new..."
    git clone --branch $branch0 --depth=1 $url0
    # https://zhuanlan.zhihu.com/p/597688197
    # git pull --unshallow
else
    echo "invalid option"
    Usage
fi

