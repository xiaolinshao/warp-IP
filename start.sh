chcp 936
cls
@echo off & setlocal enabledelayedexpansion
goto start

:start
if not exist "warp.exe" echo 缺少 warp.exe 程序 & pause & exit
if not exist "ips-v4.txt" echo 缺少 IPV4 数据 ips-v4.txt & pause & exit
goto main

:main
title WARP IPv4 Endpoint IP 优选 & set filename=ips-v4.txt & goto getv4
cls


:getv4
for /f "delims=" %%i in (%filename%) do (
set !random!_%%i=randomsort
)
for /f "tokens=2,3,4 delims=_.=" %%i in ('set ^| findstr =randomsort ^| sort /m 10240') do (
call :randomcidrv4
if not defined %%i.%%j.%%k.!cidr! set %%i.%%j.%%k.!cidr!=anycastip&set /a n+=1
if !n! EQU 100 goto getip
)
goto getv4

:randomcidrv4
set /a cidr=%random%%%256
goto :eof


:getip
del ip.txt > nul 2>&1
for /f "tokens=1 delims==" %%i in ('set ^| findstr =randomsort') do (
set %%i=
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
echo %%i>>ip.txt
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
set %%i=
)

warp
echo ===============================
format
del ip.txt > nul 2>&1
del result.csv > nul 2>&1
echo 请按任意键关闭窗口
pause > nul
exit