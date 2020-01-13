@echo off
echo @describe Find out all lastUpdated, and delete its.
echo @github https://github.com/cjunn/script_tool/
echo @author cjunn
echo @date Mon Jan 13 2020 13:13:56 GMT+0800
:again
set /p REPOSITORY_PATH=Please enter the local Maven warehouse Path:
:: Remove all double quotes
set REPOSITORY_PATH=%REPOSITORY_PATH:"=%
if not exist "%REPOSITORY_PATH%" (
   echo Maven warehouse address not found, please try again.
   goto again
)
for /f "delims=" %%i in ('dir /b /s "%REPOSITORY_PATH%\*lastUpdated*"') do (
	del /s /q "%%i"
)
echo Expired files deleted successfully.
pause;