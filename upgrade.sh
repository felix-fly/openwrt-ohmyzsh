#!/bin/sh

REMOTE=${REMOTE:-https://codeload.github.com/ohmyzsh/ohmyzsh/zip/master}
FILE=${FILE:-ohmyzsh-master}

wget "$REMOTE" -O "${FILE}.zip" || {
    printf "Update oh-my-zsh failed."
    exit 1
}

# check plugins status
if [ ! -d "${ZSH}/plugins" ]; then
    plugins=false
else
    plugins=true
fi

unzip "${FILE}.zip" > /dev/null
rm -rf "$ZSH"
mv "$FILE" "$ZSH"
rm -f "${FILE}.zip"

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
