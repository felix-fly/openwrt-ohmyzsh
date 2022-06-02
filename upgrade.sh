#!/bin/sh

REMOTE=${REMOTE:-https://codeload.github.com/ohmyzsh/ohmyzsh/tar.gz/refs/heads/master}

wget "$REMOTE" -O- | tar xz -C "$ZSH" --strip-components 1 > /dev/null || {
    printf "Download oh-my-zsh failed"
    exit 1
}

# check plugins status
if [ ! -d "${ZSH}/plugins" ]; then
    plugins=false
else
    plugins=true
fi

# replace upgrade.sh
wget https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/upgrade.sh -O "${ZSH}/tools/upgrade.sh"
# patch to check_for_upgrade.sh
sed -i '/^whence git.*/d' "${ZSH}/tools/check_for_upgrade.sh"
# fix for remove lock file
mkdir "$ZSH/log/update.lock" 2>/dev/null

# remove plugins
if [[ $plugins != true ]]; then
    rm -rf "${ZSH}/plugins"
fi

printf "Update oh-my-zsh successful."
