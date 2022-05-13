# 在 openwrt 中安装 oh-my-zsh

oh-my-zsh 官方的安装脚本需要预先安装 git 和 git-http，但是这两个包对于小内存的路由器来说实在是太大了。此处的脚本是基于官方脚本改造的，不使用git而是通过wget获取源码的tar.gz包的方式来安装。

## 依赖的包

* wget
* zsh
* ca-certificates

```bash
opkg update
opkg install wget zsh ca-certificates
```

## 安装

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/install.sh)"
```

## 设置 zsh 为默认 shell

```bash
which zsh && sed -i -- 's:/bin/ash:'`which zsh`':g' /etc/passwd
```

重新登录到路由器，就是 oh-my-zsh 了。

## 卸载

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/uninstall.sh)"
```
