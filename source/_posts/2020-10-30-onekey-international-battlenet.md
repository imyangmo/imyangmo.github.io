---
title: 国服战网一键改国际服地区脚本
date: 2020-10-30 22:21:01
tags:
 - 战网
 - Battle.net
 - Battlenet
 - 国际服
 - 脚本
---
大家都知道国服在全球的位置独一无二，但是实际上战网客户端是全球通用的，对于动手能力不强的同学，写了个脚本可以一键换国际服。
<!-- more -->

## 自己动手改的方法
1. 找到路径 C:\Users\{你的用户名}\AppData\Roaming\Battle.net下的Battle.net.config文件
2. 用记事本打开，用 Ctrl + F 搜索 AllowedRegions
4. 在该项后面把 CN 改为 CN;EU;US;KR;
5. 保存记事本并退出
6. 重新打开战网客户端即可选择其他外服

## 或者用一键脚本代码
```
@echo off

cd %USERPROFILE%\AppData\Roaming\Battle.net
ren Battle.net.config Battle.net.config.bak
set "origin_file=Battle.net.config.bak"
set "new_file=Battle.net.config"

(for /f "delims=" %%a in (%origin_file%) do (
  set "str=%%a"
  setlocal enabledelayedexpansion
  set "str=!str:"AllowedRegions": "CN="AllowedRegions": "CN;EU;US;KR;!"
  echo,!str!
  endlocal
))>"%new_file%"

```
或者有了代码还不知道怎么用的，[点此](https://prelude.cc/whoami/battlenet.bat)下载保存后双击运行。