@echo off
cls
echo Windows 10 Optimization Script - Admin Rights Required
echo Please run this script as Administrator!
pause

:: Gereksinimler
echo Gereksinimler:
echo Hizmet_durdur.bat adlı bir dosya
echo Diskinizde 12GB yer.
pause

:: 1. Servislerin devre dışı bırakılması
echo Disabling unnecessary services...
sc config PimIndexMaintenanceSvc start= disabled
sc config OneSyncSvc start= disabled
sc config CDPSvc start= disabled
sc config WpnUserService start= disabled
sc config MessagingService start= disabled
sc config sysmain start= disabled
sc config DialogBlockingService start= disabled
sc config diagsvc start= disabled
sc config fhsvc start= disabled
sc config AssignedAccessManagerSvc start= disabled
sc config AJRouter start= disabled
sc config SCPolicySvc start= disabled
sc config UevAgentService start= disabled
sc config UserDataSvc start= disabled
sc config UnistoreSvc start= disabled
sc config FDResPub start= disabled
sc config diagnosticshub.standardcollector.service start= disabled
sc config NetTcpPortSharing start= disabled
echo Services have been disabled.

:: 2. Telemetriyi Kapatma
echo Stopping and deleting telemetry services...
sc delete DiagTrack  
sc delete dmwappushservice
echo. > c:\ProgramData\Microsoft\Diagnosis\ETLLogs\Autologger\AutoLogger-Diagtrack-Listener.etl
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection /v AllowTelemetry /t REG_DWORD /d 0 /f
echo Telemetry services stopped.

:: 3. Kayıt Defteri Güncellemeleri
echo Applying registry tweaks...
regedit /s Disable_Windows_Defender.reg
regedit /s Power_Settings.reg
regedit /s Performance_Enhancements.reg
regedit /s CPU_performance_unlocking.reg
echo Registry tweaks applied.

:: 3.2 Grup İlke Düzenlemeleri
echo Disabling Windows Defender via Group Policy...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
echo Windows Defender has been disabled through Group Policy.

echo Disabling Windows Defender updates via Group Policy...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SignatureUpdate" /v "DisableSignatureUpdate" /t REG_DWORD /d 1 /f
echo Windows Defender update has been disabled via Group Policy.

echo Disabling telemetry through Group Policy...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
echo Telemetry has been disabled through Group Policy.

:: Grup İlkesini Güncelle
echo Updating Group Policy...
gpupdate /force
echo Group Policy has been updated.


:: 4. Güç Yönetimi ve Performans Ayarları
echo Configuring power management and CPU performance settings...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\75b0ae3f-bce0-45a7-8c89-c9611c25e100" /v "Attributes" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\5d76a2ca-e8c0-402f-a133-2158492d58ad" /v "Attributes" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb" /v "Attributes" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Intelppm" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Processor" /v "Start" /t REG_DWORD /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f
echo Power settings configured.

:: 5. Sanal Bellek ve Sayfa Dosyası Ayarları
echo Configuring page file and virtual memory settings...
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=2000,MaximumSize=12000
wmic pagefileset where name="E:\\pagefile.sys" delete
echo Page file settings updated.

:: 6. Görev Zamanlayıcı Ayarları
echo Disabling scheduled tasks...
schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable
schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE
echo Scheduled tasks disabled.

:: 7. Sistem Dosyalarını Onarma ve Temizleme
echo Repairing system files and cleaning up...
sfc /scannow
chkdsk C: /scan /f
dism /online /cleanup-image /restorehealth
cleanmgr /sagerun:1
defrag C: /O /H
defrag E: /O /H
echo System repair and cleanup completed.

:: 8. Kısayol ve Başlangıç Ayarları
echo Creating shortcut for "hizmet_durdur.bat" in Startup...
set source="%~dp0hizmet_durdur.bat"
set shortcut="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\hizmet_durdur_kisayolu.lnk"
echo Set WshShell = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo Set Shortcut = WshShell.CreateShortcut(%shortcut%) >> "%TEMP%\CreateShortcut.vbs"
echo Shortcut.TargetPath = %source% >> "%TEMP%\CreateShortcut.vbs"
echo Shortcut.WorkingDirectory = "%~dp0" >> "%TEMP%\CreateShortcut.vbs"
echo Shortcut.Save >> "%TEMP%\CreateShortcut.vbs"
cscript //nologo "%TEMP%\CreateShortcut.vbs"
del "%TEMP%\CreateShortcut.vbs"
echo Shortcut created.

:: 9. Bilgilendirme
echo Optimization and configuration completed successfully!
echo Restart your system for changes to take effect.
pause
exit
