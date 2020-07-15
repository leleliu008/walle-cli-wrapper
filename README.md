# walle-cli-wrapper
a POSIX sh script wrapper for [walle-cli](https://github.com/Meituan-Dianping/walle/tree/master/walle-cli) that helps you to use this command-line tool quickly and easily.

## Install via package manager

|OS|PackageManager|Installation Instructions|
|-|-|-|
|`macOS`|[HomeBrew](http://blog.fpliu.com/it/os/macOS/software/HomeBrew)|`brew tap leleliu008/fpliu`<br>`brew install walle-cli`|
|`GNU/Linux`|[LinuxBrew](http://blog.fpliu.com/it/software/LinuxBrew)|`brew tap leleliu008/fpliu`<br>`brew install walle-cli`|
|`ArchLinux`<br>`ArcoLinux`<br>`Manjaro Linux`<br>`Windows/msys2`|[pacman](http://blog.fpliu.com/it/software/pacman)|`curl -LO https://github.com/leleliu008/androidx/releases/download/v1.1.6/walle-cli-1.1.6-1-any.pkg.tar.gz`<br>`pacman -Syyu --noconfirm`<br>`pacman -U walle-cli-1.1.6-1-any.pkg.tar.gz`|
|`Windows/WSL`|[LinuxBrew](http://blog.fpliu.com/it/software/LinuxBrew)|`brew tap leleliu008/fpliu`<br>`brew install walle-cli`|

## Install using shell script
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/leleliu008/walle-cli-wrapper/master/install.sh)"
```

## zsh-completion for walle command
I have provide a zsh-completion script for `walle` command. when you've typed `walle` then type `TAB` key, it will auto complete the rest for you.

**Note**: to apply this feature, you may need to run the command `autoload -U compinit && compinit`
