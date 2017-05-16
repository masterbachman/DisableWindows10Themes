@ECHO OFF

:--------------------------------------
:--------------------------------------
:: This block runs the .BAT as an administrator
:: BatchGotAdmin
:: https://superuser.com/questions/788924/is-it-possible-to-automatically-run-a-batch-file-as-administrator
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
:--------------------------------------


:: Windows Accessibility and Themes toggle.
SET /P accessibility="ENABLE/DISABLE Windows Acessibilty and Themes (type enable, disable): "

2>NUL CALL :CASE_%accessibility% # jump to :CASE_enable, :CASE_disable, etc.
IF ERRORLEVEL 1 CALL :DEFAULT_CASE # if label doesn't exist

ECHO PROCESSS COMPLETE.
PAUSE
EXIT /B

:CASE_disable
  :: (0 = default, 1 = enable restriction)
  REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Utilman.exe" /v "Debugger" /t REG_SZ /d "systray.exe" /f
  REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoThemesTab" /t REG_DWORD /f /d 1
  REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoThemesTab" /t REG_DWORD /f /d 1
  TAKEDOWN /a /f C:\Windows\Resources\Ease of Access Themes /r /d y
  MOVE "C:\Windows\Resources\Ease of Access Themes" "C:\Windows\Ease of Access Themes"
  DEL "%localAppData%\Microsoft\Windows\Themes\*.*?"
  ECHO Acessibilty and Windows Themes are now DISABLED.
  GOTO END_CASE
:CASE_enable
  :: (0 = default, 1 = enable restriction)
  REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoThemesTab" /t REG_DWORD /f /d 0
  REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoThemesTab" /t REG_DWORD /f /d 0  
  REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Utilman.exe" /v "Debugger" /f
  REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoThemesTab" /f 
  TAKEDOWN /a /f C:\Windows\Resources\Ease of Access Themes /r /d y
  MOVE "C:\Windows\Ease of Access Themes" "C:\Windows\Resources\Ease of Access Themes"
  ECHO Acessibilty and Windows Themes are now ENABLED.
  GOTO END_CASE
:DEFAULT_CASE
  ECHO Unknown entry "%accessibility%"
  GOTO END_CASE
:END_CASE
  VER > NUL # reset ERRORLEVEL
  GOTO :EOF # return from CALL
  