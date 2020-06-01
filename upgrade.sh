#!/bin/sh

REMOTE=${REMOTE:-https://codeload.github.com/ohmyzsh/ohmyzsh/zip/master}
FILE=${FILE:-ohmyzsh-master}

wget "$REMOTE" -O "${FILE}.zip" || {
    printf "Update oh-my-zsh failed."
    exit 1
}

unzip "${FILE}.zip" > /dev/null
rm -rf "$ZSH"
mv "$FILE" "$ZSH"
rm -f "${FILE}.zip"

# replace upgrade.sh
wget https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/upgrade.sh -O "${ZSH}/tools/upgrade.sh"
# patch to check_for_upgrade.sh
sed -i '/^whence git.*/d' "${ZSH}/tools/check_for_upgrade.sh"
sed -i '/^ \+rmdir .*/d' "${ZSH}/tools/check_for_upgrade.sh"

printf "Update oh-my-zsh successful."
