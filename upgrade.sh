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

printf "Update oh-my-zsh successful."
