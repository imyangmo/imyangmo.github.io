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
