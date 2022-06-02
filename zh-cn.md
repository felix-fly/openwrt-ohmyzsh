# 在 openwrt 中安装 oh-my-zsh

oh-my-zsh 官方的安装脚本需要预先安装 git 和 git-http，但是这两个包对于小内存的路由器来说实在是太大了。此处的脚本是基于官方脚本改造的，不使用git而是通过curl获取源码的tar.gz包的方式来安装。

## 依赖的包

* zsh

```bash
opkg update
opkg install zsh
```

## 安装

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/install.sh)"
```

## 设置 zsh 为默认 shell

```bash
which zsh && sed -i -- 's:/bin/ash:'`which zsh`':g' /etc/passwd
```

重新登录到路由器，就是 oh-my-zsh 了。

## 卸载

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/felix-fly/openwrt-ohmyzsh/master/uninstall.sh)"
```

## 问题解决

如果遇到这样的错误提示:

```bash
regexp-replace:28: failed to load module: zsh/regex
regexp-replace:28: -regex-match not available for regex
```

可以删除下面的文件来解决。

```bash
mv ~/.oh-my-zsh/lib/vcs_info.zsh ~/.oh-my-zsh/lib/vcs_info.zsh.bak
```
