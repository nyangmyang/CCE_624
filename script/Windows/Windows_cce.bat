@echo off
REM Windows.bat - Sample script for Windows systems

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set HOST_IP=%%a
set HOST_IP=%HOST_IP: =%
set JSON_FILE=C:\temp\Windows_%HOST_IP%.json

(
echo {
echo   "collection_time": "%date% %time%",
echo   "hostname": "%COMPUTERNAME%",
echo   "os": "%OS%",
echo   "architecture": "%PROCESSOR_ARCHITECTURE%",
echo   "ip_address": "%HOST_IP%",
echo   "user": "%USERNAME%",
echo   "domain": "%USERDOMAIN%"
echo }
) > "%JSON_FILE%"

echo Windows system information collected in %JSON_FILE%
