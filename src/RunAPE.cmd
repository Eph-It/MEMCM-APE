@echo off

set filename=powershell.exe

SET fileCount=0

for /f "tokens=1,*" %%a in ('tasklist ^| find /I /C "%filename%"') do set fileCount=%%a

for /f "tokens=1,* delims= " %%a in ("%*") do set ALL_BUT_FIRST=%%b

IF %fileCount% gtr 1 (
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File %0\..\APE.ps1 %*
) ELSE (
	start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -File %0\..\APE.ps1 %*
)

