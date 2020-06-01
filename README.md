# oh-my-zsh on openwrt

[查看中文说明](./zh-cn.md)

Install oh-my-zsh on a openwrt router without git and git-http installed. It's base on the official scripts.

Package git and git-http are so large for a cheap router with a little storage.

## dependence packages

* wget
* unzip
* zsh
* ca-certificates

```shell
opkg update
opkg install wget unzip zsh ca-certificates
```

## Install

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/install.sh)"
```

## Set zsh default

```shell
which zsh && sed -i -- 's:/bin/ash:'`which zsh`':g' /etc/passwd
```

Relogin your router, you'll see oh-my-zsh here.

## Uninstall

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/uninstall.sh)"
```
