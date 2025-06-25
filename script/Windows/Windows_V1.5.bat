pushd %~dp0
setlocal enabledelayedexpansion
chcp 437
set sak=.
set script=.\script
rem 환경 변수 설정
set path=%path%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32
secedit /EXPORT /CFG Local_Security_Policy.txt

::Windows Server
:Type-Server

REM %script%\psinfo.exe | find "Kernel version" | findstr /i "2012"
REM if not errorlevel 1 goto Server-2012
REM %script%\psinfo.exe | find "Kernel version" | findstr /i "2008 Vista"
REM if not errorlevel 1 goto Server-2008
REM %script%\psinfo.exe | find "Kernel version" | findstr /i "2003"
REM if not errorlevel 1 goto Server-2003
REM %script%\psinfo.exe | find "Kernel version" | findstr /i "2000"
REM if not errorlevel 1 goto Server-2000
REM %script%\psinfo.exe | find "Kernel version" | findstr /i "7 8 8.1 10"
REM if not errorlevel 1 goto Server-2012
REM %script%\psinfo.exe | find "Kernel version" | findstr /i "XP"
REM if not errorlevel 1 goto Server-XP



:Server-2012
ipconfig | find /i "IPv4 Address" | %script%\head.exe -1 | %script%\gawk.exe "{print $14}" > ip.txt
for /f "tokens=1" %%a in (ip.txt) do set IP=%%a
del ip.txt
	
rem 파일명 변경
set RESULT_FILE=Server_%COMPUTERNAME%_%IP%.txt

echo ############### Windows Security Check ###############																> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo Copyright 2023. all rights reserved. 																	            >> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ####################################  Start Time  ####################################  									>> %RESULT_FILE%
date /t                                                                                      									>> %RESULT_FILE%
time /t                                                                                      									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo. 

rem W-01 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-1] Administrator 계정 이름 바꾸기 																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [1-START] 																													>> %RESULT_FILE%
net localgroup Administrators | findstr /V "Comment Members completed" | findstr -V "Alias" | find /I "Administrator" > Nul
IF ERRORLEVEL 1 (
	ECHO Administrator 계정 존재하지 않으므로 양호함                       														>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net localgroup Administrators | findstr /V "Comment Members completed" | findstr -V "Alias" 								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [1-END]																												>> %RESULT_FILE%
	ECHO [W-1]Result : GOOD                       																				>> %RESULT_FILE%
) else (
	ECHO Administrator 계정이 존재함으로 취약함                			    													>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net localgroup Administrators | findstr /V "Comment Members completed" | findstr -V "Alias" 								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [1-END]																												>> %RESULT_FILE%
	ECHO [W-1]Result : VULNERABLE                			     																>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                           									>> %RESULT_FILE%
echo Administrator 계정 이름 바꾸기(net localgroup Administrators)                        		 								>> %RESULT_FILE%
echo Administrator 계정이 존재하면 취약                                           				 								>> %RESULT_FILE%
echo 단 Administrator계정이 일반사용자 권한이면 양호                                     			 							>> %RESULT_FILE%
echo 계정 이름 변경후 로그아웃 혹은 재시작해야 반영됨                                      				 						>> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-01 END


rem W-02 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-2] Guest 계정 상태 																										>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [2-START] 																													>> %RESULT_FILE%
net user guest | find "Account active" | find "Yes" >nul
IF ERRORLEVEL 1 (
	echo Guest 계정 비활성화 되어있으므로 양호함                            													>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net user guest | find /i "guest" | find /i "user name"                                                                      >> %RESULT_FILE%
	net user guest | find "Account active"                                                      								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [2-END]                                                                              									>> %RESULT_FILE%
	echo [W-2]Result : GOOD                                                            											>> %RESULT_FILE%
) else (
	echo GUest 계정 활성화되어있으므로 취약함                                  													>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net user guest | find /i "guest" | find /i "user name"                                                                      >> %RESULT_FILE%
	net user guest | find "Account active"                                                      								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [2-END]                                                                              									>> %RESULT_FILE%
	echo [W-2]Result : VULNERABLE                                                              									>> %RESULT_FILE%
)
echo.                                                                                      								    	>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo GUEST 계정 상태                                                                   											>> %RESULT_FILE%
echo Account active=yes - 활성화 (취약)                                             											>> %RESULT_FILE%
echo Account active=no  - 비활성화 (양호)                                                										>> %RESULT_FILE%
echo Guset계정이 존재하지 않아도 양호                                                    										>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.   																														>> %RESULT_FILE%
echo.   																														>> %RESULT_FILE%
rem W-02 END


rem W-03 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-3] 불필요한 계정 제거 																									>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [3-START] 																													>> %RESULT_FILE%
echo 불필요한 계정여부에 대한 인터뷰							     															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
echo "# net user"                                                    															>> %RESULT_FILE%
net user  | find /v /i "User accounts" | find /v /i "command completed"                      									>> %RESULT_FILE%                                                                     
echo #wmic useraccount get name,status                                                    										>> %RESULT_FILE%
wmic useraccount get name,status | find /v ""														>> %RESULT_FILE%
::wmic useraccount get name,status                                                    											>> %RESULT_FILE%
echo.  											     																			>> %RESULT_FILE%
echo [3-END]										     																		>> %RESULT_FILE%
echo [W-3]Result : MANUAL 							                     														>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo GUEST 계정 상태                                                                   											>> %RESULT_FILE%
echo Account active=yes - 활성화 (취약)                                             											>> %RESULT_FILE%
echo Account active=no  - 비활성화 (양호)                                                										>> %RESULT_FILE%
echo Guset계정이 존재하지 않아도 양호                                                    										>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-03 END


rem W-04 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-4] 계정 잠금 임계값 설정 																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [4-START] 																													>> %RESULT_FILE%
net accounts | find "Lockout threshold"     > tmp_4_1.txt
FOR /F "tokens=3" %%a in (tmp_4_1.txt) do SET TEMP=%%a
if %TEMP% LEQ 5 ( 
	echo 계정 잠금 임계값이 5회 이하로 설정되어 있으므로 양호함          																>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net accounts | find "Lockout threshold"                  																	>> %RESULT_FILE%
	echo.																														>> %RESULT_FILE%
	echo [4-END]   																												>> %RESULT_FILE%
	echo [W-4]Result : GOOD   																									>> %RESULT_FILE% 
) else (
	echo 계정 잠금 임계값이 5회 이하로 설정되어있지 않으므로 취약함    															>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net accounts | find "Lockout threshold"                  																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [4-END]   																												>> %RESULT_FILE%
	echo [W-4]Result : VULNERABLE   																							>> %RESULT_FILE%
)
set TEMP=
del tmp_4_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 계정 잠금 임계값 설정                                                                   									>> %RESULT_FILE%
echo 행정안전부 기준 5회 미만은 양호, 이상이면 취약으로 판정                                          							>> %RESULT_FILE%
echo 경우에 따라 수동판단                                                                   									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-04 END


rem W-05 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-5] 해독 가능한 암호화를 사용하여 암호 저장 																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [5-START] 																													>> %RESULT_FILE%
type Local_Security_Policy.txt | find /i "ClearTextPassword" | find "0"
if not errorlevel 1 (
	echo 해독 가능한 암호화 저장을 사용하지 않으므로 양호함 																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /i "ClearTextPassword" 																>> %RESULT_FILE%
	echo.  																														>> %RESULT_FILE%
	echo [5-END]																												>> %RESULT_FILE%
	echo [W-5]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 해독 가능한 암호화 저장을 사용하고 있으므로 취약함  																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /i "ClearTextPassword" 																>> %RESULT_FILE%
	echo.  																														>> %RESULT_FILE%
	echo [5-END]																												>> %RESULT_FILE%
	echo [W-5]Result : VULNERABLE 																								>> %RESULT_FILE%
)																																 
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                           									>> %RESULT_FILE%
echo 해독 가능한 암호를 사용하여 암호 저장                                                   									>> %RESULT_FILE%
echo 사용 안함 : ClearTextPassword = 0 	(양호)												 									>> %RESULT_FILE%
echo 사     용 : ClearTextPassword = 1 	(취약)	  											 									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo. 
rem W-05 END


rem W-06 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-6] 관리자 그룹에 최소한의 사용자 포함 																					>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [6-START] 																													>> %RESULT_FILE%
net localgroup Administrators | %script%\sed.exe -n "7,/successfully/p" | find /v "successfully" > tmp_6_1.txt
type tmp_6_1.txt | %script%\wc -l | find "1"
if not errorlevel 1 (
	echo 관리자 그룹에 1개의 계정만 존재함으로 양호함 																			>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_6_1.txt 																											>> %RESULT_FILE%
	echo.  																														>> %RESULT_FILE%
	echo [6-END]																												>> %RESULT_FILE%
	echo [W-6]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 관리자 그룹에 2개 이상의 계정이 존재함으로 취약함 																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_6_1.txt 																											>> %RESULT_FILE%
	echo.  																														>> %RESULT_FILE%
	echo [6-END] 																												>> %RESULT_FILE%
	echo [W-6]Result : MANUAL																									>> %RESULT_FILE% 
) 																								
del tmp_6_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                           									>> %RESULT_FILE%
echo 관리자 그룹에 최소한의 사용자 포함                                                      									>> %RESULT_FILE%
echo *관리자 그룹의 계정이 두개 이상일 경우 인터뷰를 통해 확인이 필요함                     									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%                                                                                        >> %RESULT_FILE%
echo. 
rem W-06 END


rem W-07 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-7] Everyone 사용 권한을 익명 사용자에게 적용 																			>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [7-START] 																													>> %RESULT_FILE%
reg query HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Lsa\ | find "everyoneincludesanonymous" | find "0x0" > nul
IF NOT ERRORLEVEL 1 (
	ECHO Everyone 사용 권한을 익명 사용자에게 적용하지 않으므로 양호함                           								>> %RESULT_FILE% 
	echo. 																														>> %RESULT_FILE%
	echo [현황]                                                                                        							>> %RESULT_FILE%
	reg query HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Lsa\ | find "everyoneincludesanonymous"                           >> %RESULT_FILE%
	echo.                                                                                										>> %RESULT_FILE%
	echo [7-END] 																												>> %RESULT_FILE%
	echo [W-7]Result : GOOD                                                          											>> %RESULT_FILE%
) else (
	ECHO Everyone 사용 권한을 익명 사용자에게 적용함으로 취약함                                									>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황]                                                                                        							>> %RESULT_FILE%
	reg query HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Lsa\ | find "everyoneincludesanonymous"                           >> %RESULT_FILE%
	echo.                                                                                										>> %RESULT_FILE%
	echo [7-END] 																												>> %RESULT_FILE%
	echo [W-7]Result : VULNERABLE                                                              									>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                           									>> %RESULT_FILE%
echo Everyone 사용 권한을 익명 사용자에게 적용                                               									>> %RESULT_FILE%
echo everyoneincludesanonymous = 0 사용안함   (양호)                                         									>> %RESULT_FILE%
echo everyoneincludesanonymous = 1 사용함     (취약)                                         									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.    
rem W-07 END


rem W-08 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-8] 계정 잠금 기간 설정 																									>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [8-START] 																													>> %RESULT_FILE%
net accounts | find "Lockout duration"						     > tmp_8_1.txt
net accounts | find "Lockout observation"                        > tmp_8_2.txt
net accounts | find "Lockout threshold"    						 > tmp_8_3.txt
FOR /F "tokens=3" %%a in (tmp_8_3.txt) do SET TEMP1=%%a
FOR /F "tokens=4" %%i in (tmp_8_1.txt) do SET TEMP2=%%i
FOR /F "tokens=5" %%j in (tmp_8_2.txt) do SET TEMP3=%%j
set TEMP4=Never
If %TEMP1% == %TEMP4% ( 
	echo 계정 임계값이 설정 되어 있지 않으므로 취약                           													>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
    net accounts | find "Lockout"
	echo [8-END]                                                     															>> %RESULT_FILE%
    echo [W-8]Result : VULNERABLE  								                     											>> %RESULT_FILE%
) else (
	IF %TEMP2% LSS 60 (
		echo 계정 잠금 기간 및 잠금 기간 원래대로 설정이 60분이하 이므로 취약함                     							>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		net accounts | find "Lockout"                          														>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [8-END]                                                                              								>> %RESULT_FILE%
		echo [W-8]Result : VULNERABLE								                     										>> %RESULT_FILE%
	) else (
		IF %TEMP3% GEQ 60 (
			echo 계정 잠금 기간 및 잠금 기간 원래대로 설정이 각각 60분이상이므로 양호함  										>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			net accounts | find "Lockout"                          													>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [8-END]                                                                               							>> %RESULT_FILE%
			echo [W-8]Result : GOOD                                                                               				>> %RESULT_FILE%
		) else (
			echo 계정 잠금 기간 원래대로 설정이 60분 이하이므로 취약함                           								>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			net accounts | find "Lockout"                          													>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [8-END]                                                     													>> %RESULT_FILE%
			echo [W-8]Result : VULNERABLE  								                     									>> %RESULT_FILE%
		)
	)
)
set TEMP1=
set TEMP2=
set TEMP3=
set TEMP4=
del tmp_8_3.txt
del tmp_8_1.txt
del tmp_8_2.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                            									>> %RESULT_FILE%
echo 계정 잠금 기간 설정                                                                 										>> %RESULT_FILE%
echo Lockout duration (minutes) = 계정 잠금 기간설정(60분이상 양호)                      			 							>> %RESULT_FILE%
echo Lockout observation window (minutes) = 다음 시간 후 계정 잠금 수를                  			 							>> %RESULT_FILE%
echo 원래대로 설정 (60분이상 양호)                                                     	         								>> %RESULT_FILE%
echo 위 2가지 값이 모두 60분이상으로 만족해야 양호로 판정                                				 						>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-8 END


rem W-9 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-9] 패스워드 복잡성 설정 																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [9-START] 																													>> %RESULT_FILE%
type Local_Security_Policy.txt | find /I "PasswordComplexity" | find "1" > NUL    
IF NOT ERRORLEVEL 1 (
	echo 패스워드 복잡성 설정을 사용하고있으므로 양호함  																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /I "PasswordComplexity"                                								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [9-END]                                                                               									>> %RESULT_FILE%
	echo [W-9]Result : GOOD                                                           											>> %RESULT_FILE%
) else (                    									
	echo 패스워드 복잡성 설정을 사용하고있지 않으므로 취약함                     												>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /I "PasswordComplexity"                                								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [9-END]                                                                               									>> %RESULT_FILE%
	echo [W-9]Result : VULNERABLE                                                                								>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 패스워드 복잡성 설정                                                                   									>> %RESULT_FILE%
echo PasswordComplexity = 0 (패스워드 복잡성 미사용 - 취약)                                    									>> %RESULT_FILE%
echo PasswordComplexity = 1 (패스워드 복잡성 정책 사용- 양호)                                 									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                       									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-9 END


rem W-10 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-10] 패스워드 최소 암호 길이 																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [10-START] 																												>> %RESULT_FILE%
net accounts | find "length" | %script%\sed.exe "s/: */:     /" > tmp_10_1.txt
for /f "tokens=4" %%a in (tmp_10_1.txt) do set var=%%a
if %var% LEQ 7 (
	echo 패스워드 최소 길이 설정이 정책에 맞지 않으므로 취약함 																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_10_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [10-END] 																												>> %RESULT_FILE%
	echo [W-10]Result : VULNERABLE 																								>> %RESULT_FILE%
) else (
	echo 패스워드 최소 길이 설정이 정책에 맞게 설정되어 있으므로 양호함 														>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_10_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [10-END] 																												>> %RESULT_FILE%
	echo [W-10]Result : GOOD 																									>> %RESULT_FILE% 
)
del tmp_10_1.txt
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 최소 패스워드 길이 설정 8문자 이상 설정                                                              	 					>> %RESULT_FILE%
echo Minimum password length = 패스워드 최소 길이                                        										>> %RESULT_FILE%
echo 값이 8일 이상이면 양호 / 8일 미만 이면 취약                                                     							>> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.																															>> %RESULT_FILE%
echo.																															>> %RESULT_FILE%
rem W-10 END


rem W-11 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-11] 패스워드 최대 사용 기간 																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [11-START] 																												>> %RESULT_FILE%
net accounts | find "Maximum password"    >   tmp_11_1.txt
FOR /F "tokens=5" %%l in (tmp_11_1.txt) do SET TEMP=%%l																			>> %RESULT_FILE%
IF %TEMP% NEQ Unlimited (
	IF %TEMP% GTR 90 (
		echo 패스워드 최대 사용 기간이 91일 이상으으로 설정되어있어 취약함     													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		net accounts | find "Maximum password"							     													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%		
		echo [11-END]                                                                               							>> %RESULT_FILE%
		echo [W-11]Result : VULNERABLE 								                     										>> %RESULT_FILE%
	) else (
		echo 패스워드 최대 사용 기간이 90일 이하으로 설정되어있어  양호함   													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		net accounts | find "Maximum password"							     													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [11-END]                                                                               							>> %RESULT_FILE%
		echo [W-11]Result : GOOD                                                                              					>> %RESULT_FILE%
	)
) else (
	echo 패스워드 최대 사용 기간이 설정되어있지 않으므로 취약함     															>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net accounts | find "Maximum password"							    														>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%	
	echo [11-END]                                                                               								>> %RESULT_FILE%
	echo [W-11]Result : VULNERABLE 	>> %RESULT_FILE%
)
set TEMP=
del tmp_11_1.txt
echo. 																															>> %RESULT_FILE%
echo.																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 패스워드 최대 사용 기간                                                                									>> %RESULT_FILE%
echo Maximum password = 패스워드 최대 사용기간(일단위)                                        									>> %RESULT_FILE%
echo 값이 90일 이하이면 양호 / 90일 미만 이면 취약                                                     							>> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-11 END


rem W-12 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-12] 패스워드 최소 사용 기간  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [12-START] 																												>> %RESULT_FILE%
net accounts | find "Minimum password age"    >   tmp_12_1.txt
FOR /F "tokens=5" %%n in (tmp_12_1.txt) do SET TEMP=%%n
IF %TEMP% LSS 1 ( 
	echo 패스워드 최소 사용 기간이 설정되어있지 않으므로 취약함   																>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net accounts | find "Minimum password age"							     													>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [12-END]                                                                               								>> %RESULT_FILE%
	echo [W-12]Result : VULNERABLE								                     											>> %RESULT_FILE%
) else (
	echo 패스워드 최소 사용 기간이 1일이상으로 설정되어있어 양호함                           									>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net accounts | find "Minimum password age"							                         								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [12-END]                                                                               								>> %RESULT_FILE%
	echo [W-12]Result : GOOD                                                                               						>> %RESULT_FILE%
)
set TEMP=
del tmp_12_1.txt
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 패스워드 최소 사용 기간                                                                									>> %RESULT_FILE%
echo Minimum password age = 패스워드 최소 사용기간(일단위)                                        								>> %RESULT_FILE%
echo 값이 1일 이상이면 양호 0이면 취약                                                     										>> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.                                                                                 											>> %RESULT_FILE%
echo.                                                                                 											>> %RESULT_FILE%
rem W-12 END


rem W-13 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-13] 마지막 사용자 이름 표시 안함 																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [13-START] 																												>> %RESULT_FILE%
%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find /i "DontDisplayLastUserName" | find "1" > NUL
if not errorlevel 1 (
	echo 마지막 사용자 이름 표시 안함 보안옵션이 '사용'으로 설정되어 있으므로 양호함 											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find /i "DontDisplayLastUserName" >> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [13-END] 																												>> %RESULT_FILE%
	echo [W-13]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 마지막 사용자 이름 표시 안함 보안옵션이 '사용안함'으로 설정되어 있으므로 취약함 										>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find /i "DontDisplayLastUserName" >> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [13-END] 																												>> %RESULT_FILE%
	echo [W-13]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
echo.                                                                                        									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 마지막 사용자 이름 표시 안함                                                                								>> %RESULT_FILE%
echo DontDisplayLastUserName = 0 (마지막 사용자 이름 표시함)-취약                                      							>> %RESULT_FILE%
echo DontDisplayLastUserName = 1 (마지막 사용자 이름 표시안함)-양호                                       						>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-13 END


rem W-14 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-14] 로컬 로그온 허용 																									>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [14-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | find /i "SeInteractiveLogonRight" > tmp_14_1.txt
type tmp_14_1.txt | %script%\gawk.exe "{print $3}" | %script%\tr.exe , \n > tmp_14_2.txt
type tmp_14_2.txt | findstr /v "IUSR_ *S-1-5-21 *S-1-5-32-544" | %script%\wc.exe -l > tmp_14_3.txt
for /f "tokens=1" %%a in (tmp_14_3.txt) do set var=%%a
if %var% GEQ 1 (
	echo 로컬 로그온 허용 계정에 administrators, IUSR 계정 이외의 계정이 존재하므로 취약함 										>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_14_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [14-END] 																												>> %RESULT_FILE%
	echo [W-14]Result : VULNERABLE 																								>> %RESULT_FILE%
) else (
	echo 로컬 로그온 허용 계정에 administrators, IUSR 계정 이외의 계정이 존재하지 않으므로 양호함 								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_14_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [14-END] 																												>> %RESULT_FILE%
	echo [W-14]Result : GOOD 																									>> %RESULT_FILE% 
)
del tmp_14_1.txt
del tmp_14_2.txt
del tmp_14_3.txt
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 로컬 로그온 허용                                                                											>> %RESULT_FILE%
echo SeInteractiveLogonRight = 로컬 로그온 가능한 사용자현황                     												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo 값에 Administrators , IUSR_[ComputerName] 계정 이외의 계정이 들어가면 취약(안행부 고시기준)         						>> %RESULT_FILE%
echo -------------알려진 로컬ID 리스트  ---------    																			>> %RESULT_FILE%
echo Administrators의 디폴트 ID값  = *S-1-5-32-544                                 												>> %RESULT_FILE% 
echo IUSR_[ComputerName]           = *S-1-5-17                                            										>> %RESULT_FILE%
echo Users 						= *S-1-5-32-545                                                    								>> %RESULT_FILE%
echo Guests						= *S-1-5-32-546												 									>> %RESULT_FILE%
echo Power Users                   = *S-1-5-32-547 											 									>> %RESULT_FILE%
echo Backup Operators              = *S-1-5-32-551                                           									>> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE% 
rem W-14 END


rem W-15 START
echo ############################################################ 																>> %RESULT_FILE%
echo [W-15] 익명 SID/이름 변환 허용 																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [15-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | Find /I "LSAAnonymousNameLookup" | Find "0" >NUL
IF NOT ERRORLEVEL 1 (
	echo 익명 SID/이름 변환 허용정책을 사용안함으로 양호함  																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "LSAAnonymousNameLookup"                            								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [15-END]                                                                              									>> %RESULT_FILE%
	echo [W-15]Result : GOOD                                                         											>> %RESULT_FILE%
) else (                                                    
	echo 익명 SID/이름 변환 허용정책을 사용함으로 취약함                                                         				>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "LSAAnonymousNameLookup"                            								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [15-END]                                                                              									>> %RESULT_FILE%
	echo [W-15]Result : VULNERABLE                                                            									>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 익명 SID/이름 변환 허용                                                                									>> %RESULT_FILE%
echo LSAAnonymousNameLookup = 0(익명 SID/이름 변환 허용정책 사용안함) -양호                     								>> %RESULT_FILE%
echo LSAAnonymousNameLookup = 1(익명 SID/이름 변환 허용정책 사용함)   -취약                     								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                      										>> %RESULT_FILE%
echo.                                                                                      										>> %RESULT_FILE%
rem W-15 END


rem W-16 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-16] 최근 암호 기억 																										>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [16-START] 																												>> %RESULT_FILE%
net accounts | find "history"    >   tmp_16_1.txt
FOR /F "tokens=6" %%l in (tmp_16_1.txt) do SET TEMP=%%l
IF %TEMP% LSS 4 (
	echo 최근 암호 기억횟수가 4회 미만이므로 취약함     																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_16_1.txt							     																			>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%	
	echo [16-END]                                                                               								>> %RESULT_FILE%
	echo [W-16]Result : VULNERABLE     								                     										>> %RESULT_FILE%
) else (
	type tmp_16_1.txt | find /I "none" 
	if not errorlevel 1 (
		echo 최근 암호 기억횟수가 설정되어있지 않으므로 취약함  																>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_16_1.txt							     																		>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [16-END]                                                                               							>> %RESULT_FILE%
		echo [W-16]Result : VULNERABLE      																					>> %RESULT_FILE%
	) else (
		echo 최근 암호 기억횟수가 4회 이상 설정되어있으므로 양호함  	 														>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_16_1.txt							     																		>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [16-END]                                                                               							>> %RESULT_FILE%
		echo [W-16]Result : GOOD        																						>> %RESULT_FILE%
	)
)
set TEMP=
del tmp_16_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 최근 암호 기억                                                                												>> %RESULT_FILE%
echo Length of password history maintained = 최근암호기억횟수                                        							>> %RESULT_FILE%
echo None 또는 12미만이면 취약 12이상은 양호                                             										>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-16 END


rem W-17 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-17] 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 																		>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [17-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | Find /I "LimitBlankPasswordUse" | Find "4,1" >NUL
IF NOT ERRORLEVEL 1 (
	echo 콘솔 로그온시 로컬 계정에서 빈 암호 사용을 제한하고있어 양호함      													>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "LimitBlankPasswordUse"                             								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [17-END]                                                                            									>> %RESULT_FILE%
	echo [W-17]Result : GOOD                                                         											>> %RESULT_FILE%
) else (
	echo 콘솔 로그온시 로컬 계정에서 빈 암호 사용을 제한하지 않고있어 취약함     												>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "LimitBlankPasswordUse"                             								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [17-END]                                                                            									>> %RESULT_FILE%
	echo [W-17]Result : VULNERABLE                                                             									>> %RESULT_FILE%
)
echo. 																															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 콘솔 로그온시 로컬 계정에서 빈 암호 사용 제한                                                                				>> %RESULT_FILE%
echo LimitBlankPasswordUse= 4,0 (빈 암호 제한 사용안함)-취약                                         							>> %RESULT_FILE%
echo LimitBlankPasswordUse= 4,1 (빈 암호 제한  사용)-양호                                         								>> %RESULT_FILE%
echo 4,0 = 취약 4,1 = 양호                                              														>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.   																															>> %RESULT_FILE%
rem W-17 END


rem W-18 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-18] 원격터미널 접속 가능한 사용자 그룹 제한 																			>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [18-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | find /i "SeRemoteInteractiveLogonRight" > tmp_18_1.txt
type tmp_18_1.txt | %script%\gawk.exe "{print $3}" | %script%\tr.exe , \n > tmp_18_2.txt
type tmp_18_2.txt | find /v "*S-1-5-32-544" | %script%\wc.exe -l > tmp_18_3.txt
for /f "tokens=1" %%a in (tmp_18_3.txt) do set var=%%a
if %var% EQU 0 (
	echo 원격터미널 접속 가능한 사용자에 administrators 이외의 계정이 존재하지 않음 											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" | find "fDenyTSConnections" 				>> %RESULT_FILE%
	type tmp_18_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [18-END] 																												>> %RESULT_FILE%
	echo [W-18]Result : GOOD 																									>> %RESULT_FILE% 
) else (
	type tmp_18_2.txt | findstr /v "*S-1-5-32-544 *S-1-5-32-555" | %script%\wc.exe -l > tmp_18_4.txt
	for /f "tokens=1" %%a in (tmp_18_4.txt) do set var=%%a
	if %var% LSS 1 ( 
		net localgroup "remote desktop users" | %script%\sed.exe -n "7,/successfully/p" | find /v "successfully" | %script%\wc.exe -w > tmp_18_5.txt
		for /f "tokens=1" %%a in (tmp_18_5.txt) do set var=%%a
		if %var% LSS 0 (
			echo 원격터미널 접속 가능한 사용자에 administrators 이외의 remote desktop users 그룹이 있으나 해당 그룹에 계정이 존재하지 않음 >> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" | find "fDenyTSConnections" 		>> %RESULT_FILE%			
			type tmp_18_1.txt 																									>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [18-END] 																										>> %RESULT_FILE%
			echo [W-18]Result : GOOD 																							>> %RESULT_FILE% 
		) else (
			echo 원격터미널 접속 가능한 사용자에 administrators 이외의 remote desktop users 그룹이 있으며, 해당 그룹에 계정이 존재하므로 취약함 >> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" | find "fDenyTSConnections" 		>> %RESULT_FILE%
			type tmp_18_1.txt 																									>> %RESULT_FILE%
			echo [remote desktop users] 																						>> %RESULT_FILE%
			net localgroup "remote desktop users" | %script%\sed.exe -n "7,/successfully/p" | find /v "successfully" 			>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [18-END] 																										>> %RESULT_FILE%
			echo [W-18]Result : MANUAL 																							>> %RESULT_FILE% 
		)
	) else (
		echo 원격터미널 접속 가능한 사용자에 administrators, remote desktop users 이외의 계정이 존재하므로 취약함 				>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" | find "fDenyTSConnections" 			>> %RESULT_FILE%
		type tmp_18_1.txt 																										>> %RESULT_FILE%
		echo [remote desktop users] 																							>> %RESULT_FILE%
		net localgroup "remote desktop users" | %script%\sed.exe -n "7,/successfully/p" | find /v "successfully" 				>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [18-END] 																											>> %RESULT_FILE%
		echo [W-18]Result : MANUAL 																								>> %RESULT_FILE% 
	)
)
del tmp_18_1.txt
del tmp_18_2.txt
del tmp_18_3.txt
del tmp_18_4.txt
del tmp_18_5.txt
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 원격터미널 접속 가능한 사용자 그룹 제한                                                                					>> %RESULT_FILE%
echo fDenyTSConnections = 0 (이 서버를 원격 데스크톱 활성화)-수동                                                				>> %RESULT_FILE%
echo fDenyTSConnections = 1 (이 서버를 원격 데스크톱 사용안함)-양호                                              				>> %RESULT_FILE%
echo SeRemoteInteractiveLogonRight=계정 항목 (터미널 서비스를 통한 로그온 허용정책)-수동                              			>> %RESULT_FILE%
echo.-------------알려진 로컬ID 리스트  ---------    																			>> %RESULT_FILE%
echo. Administrators의 디폴트 ID값  = *S-1-5-32-544                                 											>> %RESULT_FILE% 
echo. IUSR_[ComputerName]           = *S-1-5-17                                            										>> %RESULT_FILE%
echo. Users 						= *S-1-5-32-545                                                    							>> %RESULT_FILE%
echo. Guests						= *S-1-5-32-546												 								>> %RESULT_FILE%
echo. Power Users                   = *S-1-5-32-547 											 								>> %RESULT_FILE%
echo. Backup Operators              = *S-1-5-32-551                                           									>> %RESULT_FILE%
echo. Remote Desktop Users          = *S-1-5-32-555																				>> %RESULT_FILE%
echo ----------------------------------------------                   															>> %RESULT_FILE%
echo. Administrators 를 제외한 사용자 정책을 확인하여 필요한 계정 판단             												>> %RESULT_FILE%
echo.                                                                           												>> %RESULT_FILE%
echo.                                                                           												>> %RESULT_FILE%
rem W-18 END


rem W-19 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-19] 공유 권한 및 사용자 그룹 설정 																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [19-START] 																												>> %RESULT_FILE%
net start | findstr /v "A B C D E F G H I J K L M N O P Q R T U V W X Y Z a b c d f g h i j k l m n o p q t u w x y z" | findstr "Server"
IF NOT ERRORLEVEL 1 ( 
	net share  | FIND /v "$" | FIND /i "c:\"                       > tmp_19_1.txt  
	net share  | FIND /v "$" | FIND /i "d:\"                       >> tmp_19_1.txt  
	net share  | FIND /v "$" | FIND /i "e:\"                       >> tmp_19_1.txt  
	net share  | FIND /v "$" | FIND /i "f:\"                       >> tmp_19_1.txt 
	FOR /F "tokens=1" %%j IN (tmp_19_1.txt) DO cacls %%j                                 >  tmp_19_2.txt 
	FOR /F "tokens=2" %%j IN (tmp_19_1.txt) DO cacls %%j                                 >>  tmp_19_2.txt
	FOR /F "tokens=3" %%j IN (tmp_19_1.txt) DO cacls %%j                                 >>  tmp_19_2.txt
	FOR /F "tokens=4" %%j IN (tmp_19_1.txt) DO cacls %%j                                 >>  tmp_19_2.txt
	findstr "Everyone" tmp_19_2.txt > nul
	IF NOT ERRORLEVEL 1 (
		echo 일반 공유 폴더에 Everyone 공유 그룹이 포함되어있어 취약함          												>> %RESULT_FILE%
		echo.                                                                                        							>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		Echo ===== net share =====                                                                  							>> %RESULT_FILE%
		net share | FIND /V "$"                                                                       							>> %RESULT_FILE%
		echo.                                                                                        							>> %RESULT_FILE%
		type tmp_19_2.txt | find "Everyone"                                                  									>> %RESULT_FILE%
		echo.                                                                                        							>> %RESULT_FILE%
		echo [19-END]                                                                               							>> %RESULT_FILE%
		echo [W-19]Result : VULNERABLE                                                           								>> %RESULT_FILE%
	) else (
		echo 일반 공유 폴더에 Everyoune 공유 그룹이 포함되어있지 않으므로 양호함    											>> %RESULT_FILE%
		echo.                                                                                        							>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		Echo ===== net share =====                                                                  							>> %RESULT_FILE%
		net share | FIND /V "$"                                                                       							>> %RESULT_FILE%
		echo.                                                                                        							>> %RESULT_FILE%
		type tmp_19_2.txt | find "Everyone"                                                  									>> %RESULT_FILE%
		echo.                                                                                        							>> %RESULT_FILE%
		echo [19-END]                                                                               							>> %RESULT_FILE%
		echo [W-19]Result : GOOD                                                               									>> %RESULT_FILE%
	)
) else (
	echo "Server" 공유 서비스가 구동하지 않으므로 양호함 																		>> %RESULT_FILE%
	echo [19-END]                                                                            									>> %RESULT_FILE%
	echo [W-19]Result : GOOD                                                                             						>> %RESULT_FILE%
)
del  tmp_19_1.txt
del  tmp_19_2.txt
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo Everyone 사용 권한을 익명 사용자에게 적용                                          										>> %RESULT_FILE%
echo C$, D$, Admin$, IPC$을 제외한 공유폴더에                                             										>> %RESULT_FILE%
echo (기본 공유는 20번 진단항목과 중복됨으로 제외)                                          									>> %RESULT_FILE%
echo Everyone 공유계정이 존재한다면 취약                                                 										>> %RESULT_FILE%
echo 취약이 나올경우 cacls 리스트를 보고  경로 파악                                          									>> %RESULT_FILE%
echo 폴더에 뛰어쓰기가 들어갈경우 진단불가(뛰어쓰기 폴더 수동진단)                           									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%    
rem W-19 END


rem W-20 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-20] 하드디스크 기본 공유 제거 																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [20-START] >> %RESULT_FILE%
net start | findstr /v "A B C D E F G H I J K L M N O P Q R T U V W X Y Z a b c d f g h i j k l m n o p q t u w x y z" | findstr "Server"
IF NOT ERRORLEVEL 1 (
	net share | FIND /V "IPC$" | FIND /V "command PRINT$ FAX$" | FIND "$"			     > tmp_20_1.txt
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters\AutoShareServer"   >> tmp_20_1.txt
	Type tmp_20_1.txt | Find "0"                                                             									>> %RESULT_FILE%
	net share | FIND /V "IPC$" | FIND /V "command PRINT$ FAX$" | FIND "$"
	IF ERRORLEVEL 1 (
		ECHO 하드디스크의 기본공유가 제거되었으므로 양호함                         												>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		Echo ===== net share =====                                                                  							>> %RESULT_FILE%
		net share | FIND /V "IPC$" | FIND /V "command PRINT$ FAX$" | FIND "$"                         							>> %RESULT_FILE%
		echo ===== AutoshareServer check  =====                                                       							>> %RESULT_FILE%
		Type tmp_20_1.txt | Find "0"                                                              								>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [20-END]                                                                               							>> %RESULT_FILE%
		ECHO [W-20]Result : GOOD                                                         										>> %RESULT_FILE%
	) else (
		ECHO 하드디스크의 기본공유가 존재함으로 취약함                                    										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		Echo ===== net share =====                                                                  							>> %RESULT_FILE%
		net share | FIND /V "IPC$" | FIND /V "command PRINT$ FAX$" | FIND "$"                         							>> %RESULT_FILE%
		echo ===== AutoshareServer check  =====                                                       							>> %RESULT_FILE%
		Type tmp_20_1.txt | Find "0"                                                              								>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [20-END]                                                                               							>> %RESULT_FILE%
		ECHO [W-20]Result : VULNERABLE                                                             								>> %RESULT_FILE%
	)
	del tmp_20_1.txt
) else (
	echo "Server" 공유 서비스가 구동하지 않으므로 양호함 																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [20-END]                                                                             									>> %RESULT_FILE%
	echo [W-20]Result : GOOD                                                                            						>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                         	 									>> %RESULT_FILE%
echo 하드디스크 기본 공유 제거                                                                									>> %RESULT_FILE%
echo Admin$, IPC$, C$, D$, E$ (하드디스크 기본공유)                                                                             >> %RESULT_FILE%
echo IPC$, 일반공유를 제외한 기본 공유가 존재하면 취약                                          								>> %RESULT_FILE%
echo "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters\                       									>> %RESULT_FILE%
echo AutoShareServer=기본공유폴더 금지 옵션                       																>> %RESULT_FILE%
echo 0으로 설정되어있다면 양호함(레지스트리에 항목추가)                 														>> %RESULT_FILE%
echo ------------------------------------------------------------                            									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-20 END


rem W-21 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-21] 불필요한 서비스 제거 																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [21-START] 																												>> %RESULT_FILE%
net start | findstr "Alerter ClipBook Messenger" > tmp_21_1.txt
net start | find "Simple TCP/IP Services" >> tmp_21_1.txt
type tmp_21_1.txt | %script%\wc -l | find "0"
if not errorlevel 1 (
	echo 불필요한 서비스가 실행중이지 않으므로 양호함 																			>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_21_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [21-END] 																												>> %RESULT_FILE%
	echo [W-21]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 불필요한 서비스가 실행중이므로 취약함 																					>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_21_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [21-END] 																												>> %RESULT_FILE%
	echo [W-21]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
del tmp_21_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 불필요한 서비스 제거                                                                										>> %RESULT_FILE%
echo Alerter(서버에서 클라이언트로 경고메세지를 보냄)                               											>> %RESULT_FILE%
echo Clipbook(서버내 Clipbook 을 다른 클라이언트와 공유)                            											>> %RESULT_FILE%
echo Messenger(net send 명령어를 이용하여 클라이언트에 메시지 보냄)                 											>> %RESULT_FILE%
echo Simple TCP/IP Services(Echo, Discard, Character Generator, Daytime, Quote of the Day)  									>> %RESULT_FILE%                                                                  
echo Alerter, clipbook, Messenger, Simple TCP/IP Services 서비스가 구동되어있으면 취약      									>> %RESULT_FILE%
echo ------------------------------------------------------------                            									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-21 END


rem W-22 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-22] IIS 서비스 구동 점검 																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [22-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"
	IF ERRORLEVEL 1 (
		echo IIS 서비스가 중지되어있으므로 양호함                                             									>> %RESULT_FILE%
		echo.																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		REM netstat -ano | find "80"   																								>> %RESULT_FILE%
		echo "World Wide Web Publishing Service" Disable  																		>> %RESULT_FILE%
		echo.																													>> %RESULT_FILE%
		echo [22-END] 																											>> %RESULT_FILE%
		echo [W-22]Result : GOOD  																								>> %RESULT_FILE%
	) else (
		echo IIS 서비스가 구동중이므로 취약함 																					>> %RESULT_FILE%
		echo.																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		REM netstat -ano | find "80"   																								>> %RESULT_FILE%
		echo "World Wide Web Publishing Service" Enable																			>> %RESULT_FILE% 
		echo.																													>> %RESULT_FILE%
		echo [22-END] 																											>> %RESULT_FILE%
		echo [W-22]Result : VULNERABLE 																							>> %RESULT_FILE%
	)	
echo. 																															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo. 1단계 확인 : IIS_schema 확인 (확인 불가 일수 있음)                                   										>> %RESULT_FILE%
echo. 2단계 확인 : 80포트 확인 (아파치등 다른 웹서버 구동중 일수 있음)                											>> %RESULT_FILE%
echo. 3단계 확인 : World Wide Web Publishing Service 구동 여부 확인                    											>> %RESULT_FILE%
echo. 1~3 단계 모두 확인 후 판단     									             											>> %RESULT_FILE%
echo. 구동 중일 경우 인터뷰 후 판단  																							>> %RESULT_FILE%                                                                  
echo ------------------------------------------------------------                            									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-22 END


rem W-23 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-23] IIS 디렉토리 리스팅 제거  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [23-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
	echo [23-END]                                                              													>> %RESULT_FILE%
	echo [W-23]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	type %systemroot%\system32\inetsrv\config\applicationHost.config | find /I "directoryBrowse enabled"        >     tmp_23_1.txt 
	type tmp_23_1.txt | find "true" > NUL
	IF ERRORLEVEL 1 (
		ECHO 디렉터리 리스팅 기능을 사용하지 않으므로 양호함                													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [applicationHost.config]                                                                           				>> %RESULT_FILE%
		type %systemroot%\system32\inetsrv\config\applicationHost.config | find /I "directoryBrowse enabled"        			>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [web.config]                                                              											>> %RESULT_FILE%
		type C:\inetpub\wwwroot\web.config | find "directoryBrowse enabled"             										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [23-END] 									     																	>> %RESULT_FILE%
		ECHO [W-23]Result : GOOD  			                                    	 											>> %RESULT_FILE%
	) else (
		ECHO 디렉터리 리스팅 기능을 사용함으로 취약함 	                                     									>> %RESULT_FILE% 
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [applicationHost.config]                                                                           				>> %RESULT_FILE%
		type %systemroot%\system32\inetsrv\config\applicationHost.config | find /I "directoryBrowse enabled"        			>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [web.config]                                                              											>> %RESULT_FILE%
		type C:\inetpub\wwwroot\web.config | find "directoryBrowse enabled"             										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [23-END] 									     																	>> %RESULT_FILE%
		ECHO [W-23]Result : VULNERABLE			                                     											>> %RESULT_FILE%  
	)
	del tmp_23_1.txt
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 디렉토리 리스팅 검사항목(c:\windows\system32\inetsrv\applicationHost.config)                      							>> %RESULT_FILE%
echo directoryBrowse enabled - true (디렉토리 검색 체크된상태)-취약                                      						>> %RESULT_FILE%
echo directoryBrowse enabled - false(디렉토리 검색 해제된상태)-양호                                       						>> %RESULT_FILE%
echo ※ web.config 별도 수정하였을 경우(directoryBrowse enabled=false)  														>> %RESULT_FILE%
echo ※ web.config 을 우선시 함  																								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo GUI경로 : 시작-관리도구-IIS(인터넷 정보 서비스) 관리자-서버클릭-                       									>> %RESULT_FILE%
echo 디렉터리검색 더블클릭-우측에 사용함, 사용안함 선택가능                                  									>> %RESULT_FILE%
echo 설정값 변경후 IIS 재시작해야 진단가능                                                     									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-23 END


rem W-24 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-24] IIS CGI 실행 제한  																									>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [24-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [24-END]                                                              													>> %RESULT_FILE%
	echo [W-24]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	if not exist c:\inetpub\scripts (
		echo C:\inetpub\scripts 폴더가 존재하지 않으므로 양호함 																>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [24-END] 																											>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [W-24]Result : GOOD 																								>> %RESULT_FILE% 
	) else (
		cacls c:\inetpub\scripts > tmp_24_1.txt
		type tmp_23_1.txt | find /i "everyone"
		if not errorlevel 1 (
			echo C:\inetpub\scripts 폴더의 접근권한에 Everyone 계정이 존재하므로 취약함 										>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			type tmp_24_1.txt 																									>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [24-END] 																										>> %RESULT_FILE%
			echo [WI-2]Result : VULNERABLE 																						>> %RESULT_FILE% 
		) else (
			echo C:\inetpub\scripts 폴더의 접근권한에 Everyone 계정이 존재하지 않으므로 양호함 									>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			type tmp_24_1.txt 																									>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [24-END] 																										>> %RESULT_FILE%
			echo [W-24]Result : GOOD 																							>> %RESULT_FILE% 
		)
		del tmp_24_1.txt
	)
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo c:\inetpub\scripts 폴더가 없는 경우 - 양호                                     											>> %RESULT_FILE%
echo c:\inetpub\scripts 폴더에 "everyone" 권한이 없는 경우 - 양호 				                     							>> %RESULT_FILE%
echo c:\inetpub\scripts 폴더에 "everyone" 권한이 있는 경우 - 취약                                      							>> %RESULT_FILE%
echo IIS 8.0 부터 설정값이 존재하지 않음.								  														>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-24 END


rem W-25 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-25] IIS 상위 디렉토리 접근 금지  																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [25-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [25-END]                                                              													>> %RESULT_FILE%
	echo [W-25]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	type %systemroot%\system32\inetsrv\config\applicationHost.config  | find /I "enableParentPaths"   >  tmp_25_1.txt 
	type tmp_25_1.txt | find "true" > NUL
	IF ERRORLEVEL 1 (
		ECHO 상위 디렉터리 접근 기능을 사용하지 않으므로 양호함                													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type %systemroot%\system32\inetsrv\config\applicationHost.config  | find /I "enableParentPaths"      					>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [25-END]									     																	>> %RESULT_FILE%
		ECHO [W-25]Result : GOOD 			>> %RESULT_FILE%
	) else (
		ECHO 상위 디렉터리 접근 기능을 사용함으로 취약함 	                                     								>> %RESULT_FILE%  
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type %systemroot%\system32\inetsrv\config\applicationHost.config  | find /I "enableParentPaths"      					>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [25-END]									     																	>> %RESULT_FILE%
		ECHO [W-25]Result : VULNERABLE		>> %RESULT_FILE%
	)
	del tmp_25_1.txt
)

echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 상위 디렉토리 접근 검사항목(c:\windows\system32\inetsrv\schema\IIS_schema.xml)          									>> %RESULT_FILE%            
echo EnableParentPaths="TRUE"    -  (부모 경로 사용 체크된상태)-취약                         									>> %RESULT_FILE%              
echo EnableParentPaths="FALSE"   -  (부모 경로 사용 해제된상태)-양호                        									>> %RESULT_FILE%            
echo (공란)                      -  IIS 미설치상태                                            									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo 설정값 변경후 IIS 재시작해야 적용됨                                                     									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-25 END


rem W-26 Start 
rem 수정 필요
echo ############################################################ 																>> %RESULT_FILE%
echo [W-26] IIS 불필요한 파일 제거  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [26-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [26-END]                                                              													>> %RESULT_FILE%
	echo [W-26]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	type c:\windows\system32\inetsrv\config\applicationHost.config | findstr /l IISSamples                       				>> %RESULT_FILE%
	type c:\windows\system32\inetsrv\config\applicationHost.config | findstr /l IISHelp                           				>> %RESULT_FILE%
	findstr /l  IISSamples c:\windows\system32\inetsrv\config\applicationHost.config > nul
	if errorlevel 1 (
		findstr /l  IISHelp c:\windows\system32\inetsrv\config\applicationHost.config > nul
		if errorlevel 1 (
			echo IIS에 기본적으로 설치되는 샘플 파일 미존재함으로 양호함          												>> %RESULT_FILE%
			echo.                                                                                        						>> %RESULT_FILE%
			echo [26-END] 									     																>> %RESULT_FILE%
			echo [W-26]Result : GOOD                                                             								>> %RESULT_FILE%
		) else (
			echo IIS에 기본적으로 설치되는 샘플 파일 존재함으로 취약함            												>> %RESULT_FILE%
			echo.                                                                                        						>> %RESULT_FILE%
			echo [26-END] 									    	 															>> %RESULT_FILE%
			echo [W-26]Result : VULNERABLE                                                           							>> %RESULT_FILE%
		)
	) else (
		echo IIS에 기본적으로 설치되는 샘플 파일 존재함으로 취약함            													>> %RESULT_FILE%
		echo [26-END] 									     																	>> %RESULT_FILE%
		echo [W-26]Result : VULNERABLE                                                                     						>> %RESULT_FILE%
	)
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo IIS 미구동시 N/A											 																>> %RESULT_FILE%
echo IIS 기본 파일 확인 파일 확인 파일이 존재하지 않는 경우 양호 																>> %RESULT_FILE%
echo IIS 기본 파일 IISSamples, IISHelp                                      													>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-26 END


rem W-27 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-27] IIS 웹 프로세스 권한 제한  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [27-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [27-END]                                                              													>> %RESULT_FILE%
	echo [W-27]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\IISADMIN" | find /i "ObjectName" > tmp_27_1.txt
	type tmp_27_1.txt | find /i "LocalSystem"
	if not errorlevel 1 (
		echo IIS Admin Service 서비스가 로컬시스템 계정으로 구동되고 있으므로 취약함 											>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_27_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [27-END] 																											>> %RESULT_FILE%
		echo [W-27]Result : VULNERABLE  																						>> %RESULT_FILE%
	) else (
		echo IIS Admin Service 서비스가 로컬시스템 계정으로 구동되지 않고 있으므로 양호함 										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_27_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [27-END] 																											>> %RESULT_FILE%
		echo [W-27]Result : GOOD 																								>> %RESULT_FILE% 
	)
	del tmp_27_1.txt
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo IIS 구동 계정 확인																											>> %RESULT_FILE%
echo 로컬 계정으로 실행하는 경우 취약 																							>> %RESULT_FILE%
echo 특정 계정을 생성하여 구동시 양호								                                      						>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-27 END


rem W-28 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-28] IIS 링크 사용금지  																									>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [28-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [28-END]                                                              													>> %RESULT_FILE%
	echo [W-28]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	type C:\windows\system32\inetsrv\config\applicationHost.config | %script%\sed.exe -n "/serverAutoStart\=\"true\"/,/physicalPath/p" | find /i "physicalPath" > tmp_28_1.txt
	type tmp_28_1.txt | %script%\gawk.exe "{print $3}" | %script%\gawk.exe -F= "{print $2}" > tmp_28_2.txt
	for /f "tokens=1 delims=@@" %%a in (tmp_28_2.txt) do dir /s %%a > tmp_28_3.txt
	type tmp_28_3.txt | find ".lnk"
	if errorlevel 1 (
		echo 홈 디렉토리에 바로가기 파일이 존재하지 않음 																		>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [28-END] 																											>> %RESULT_FILE%
		echo [W-28]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo 홈 디렉토리에 바로가기 파일이 존재함 																				>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_28_3.txt | find ".lnk" 																						>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [28-END] 																											>> %RESULT_FILE%
		echo [W-28]Result : VULNERABLE 																							>> %RESULT_FILE% 
	)
	del tmp_28_1.txt
	del tmp_28_2.txt
	del tmp_28_3.txt
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 다른 디렉터리나 파일들에 접근할 수 있는 심볼릭 링크, aliases, 바로가기 삭제                      							>> %RESULT_FILE%
echo 다른 디렉터리에 접근이 가능한 심볼릭 링크 등 사용 금지 																	>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-28 END


rem W-29 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-29] IIS 파일 업로드 및 다운로드 제한  																					>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [29-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [29-END]                                                              													>> %RESULT_FILE%
	echo [W-29]Result : N/A                                                             										>> %RESULT_FILE%
	echo                                                                                        								>> %RESULT_FILE%
) else (
	type c:\windows\system32\inetsrv\config\applicationHost.config | find /i "bufferingLimit" > tmp_29_1.txt
	type c:\windows\system32\inetsrv\config\applicationHost.config | find /i "maxRequestEntityAllowed" >> tmp_29_1.txt
	type tmp_29_1.txt | %script%\wc.exe -l | find "2"
	if errorlevel 1 (
		echo 파일 업로드 및 다운로드 제한 설정이 적용되지 않음 																	>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_29_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [29-END] 																											>> %RESULT_FILE%
		echo [W-29]Result : VULNERABLE 																							>> %RESULT_FILE%
	) else (
		echo 파일 업로드 및 다운로드 제한 설정이 적용됨 																		>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_29_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [29-END] 																											>> %RESULT_FILE%
		echo [W-29]Result : GOOD 																								>> %RESULT_FILE%
	)
	del tmp_29_1.txt
)
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 파일 업로드 다운로드 제한 (c:\windows\system32\inetsrv\config\schema\IIS_schema.xml)                      					>> %RESULT_FILE%
echo 윈도우 IIS7 Default 콘텐츠 용량 제한 기본 = 30Mb                                          									>> %RESULT_FILE%
echo 윈도우 IIS7 Default 다운로드제한 = 4194304바이트   업로드제한 = 200000바이트                								>> %RESULT_FILE%
echo 수동설정시 system32\inetsrv\config\applicationHost.config 명령어 구문삽입해야함           									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-29 END


rem W-30 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-30] IIS DB 연결 취약점 점검  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [30-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [30-END]                                                              													>> %RESULT_FILE%
	echo [W-30]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	DIR /s/b c:\Inetpub\Global.asa                                        														>> %RESULT_FILE%
	type %systemroot%\system32\inetsrv\config\applicationHost.config | findstr /I .asa                           
	IF NOT ERRORLEVEL 1 (
		echo .asa 매핑이 되어있으므로 양호함                                                           							>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type %systemroot%\system32\inetsrv\config\applicationHost.config | findstr /I .asa   	 								>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [30-END] 									     																	>> %RESULT_FILE%
		echo [W-30]Result : GOOD                                                         										>> %RESULT_FILE%
	) else (
		echo .asa 매핑이 되어있지 않아 Global.asa 를 호출할수있어 취약함                   										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type %systemroot%\system32\inetsrv\config\applicationHost.config | findstr /I .asa   	 								>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [30-END] 									     																	>> %RESULT_FILE%
		echo [W-30]Result : VULNERABLE                                                          								>> %RESULT_FILE%
	)
)
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                       					>> %RESULT_FILE%
echo                                         									>> %RESULT_FILE%
echo                 								>> %RESULT_FILE%
echo           									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-30 END


rem W-31 Start 업데이트 필요(값 반전 되어 나옴)
echo ############################################################ 																>> %RESULT_FILE%
echo [W-31] IIS 가상 디렉토리 삭제  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [31-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [31-END]                                                              													>> %RESULT_FILE%
	echo [W-31]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	ECHO.[IIS Version]						          			                     											>> %RESULT_FILE%
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\MajorVersion"   								>> %RESULT_FILE%
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" | find /I "/IISAdmin" > tmp_31_1.txt
	type tmp_31_1.txt                                                          													>> %RESULT_FILE%
	echo.                                                                            											>> %RESULT_FILE%
	findstr /I "admin" tmp_31_1.txt > NUL
	IF ERRORLEVEL 1 (
		echo 가상 디렉토리가 존재하지 않으므로 양호함 																			>> %RESULT_FILE% 
		echo. 																													>> %RESULT_FILE% 
		echo [31-END] 																											>> %RESULT_FILE%  
		echo [W-31]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo 가상 디렉토리가 존재함으로 취약함 																					>> %RESULT_FILE% 
		echo. 																													>> %RESULT_FILE% 
		echo [31-END] 																											>> %RESULT_FILE% 
		echo [W-31]Result : Vulnerable 																							>> %RESULT_FILE%
	)
)
del tmp_31_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo ※ IIS 6.0 이상 버전 해당 사항 없음(MajorVersion=6)                      													>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo 설정값 변경후 서비스에서 IIS 재시작해야 적용됨                 															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-31 END


rem W-32 START
echo ############################################################ 																>> %RESULT_FILE%
echo [W-32] IIS 데이터 파일 ACL 적용  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [32-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [32-END]                                                              													>> %RESULT_FILE%
	echo [W-32]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	cacls C:\Inetpub\wwwroot > tmp_32_1.txt
    type tmp_32_1.txt | find /I "everyone" > nul
	if NOT errorlevel 1 (
		echo 수동진단 필요함             																						>> %RESULT_FILE%
	    echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		cacls C:\Inetpub\wwwroot           																						>> %RESULT_FILE%
		echo [32-END]                   																						>> %RESULT_FILE%			
		echo [W-32]Result : MANUAL                   																			>> %RESULT_FILE%	
	) else (
		type tmp_32_1.txt | find /I "users" > nul
		if NOT errorlevel 1 ( 
	       echo 수동진단 필요함             																					>> %RESULT_FILE%
		   echo. 																												>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			cacls C:\Inetpub\wwwroot           																					>> %RESULT_FILE%
			echo [32-END]                   																					>> %RESULT_FILE%			
			echo [W-32]Result : MANUAL                   																		>> %RESULT_FILE%
		) else (
			type tmp_32_1.txt | find /I "IUSR_" > nul
			if NOT errorlevel 1 ( 
				echo 수동진단 필요함             																				>> %RESULT_FILE%
				echo. 																											>> %RESULT_FILE%
				echo [현황] 																									>> %RESULT_FILE%
				cacls C:\Inetpub\wwwroot           																				>> %RESULT_FILE%
				echo [32-END]                   																				>> %RESULT_FILE%			
				echo [W-32]Result : MANUAL                   																	>> %RESULT_FILE%
			) else (
				ECHO 외부 계정이 존재하지 않으므로 양호함    																	>> %RESULT_FILE%		
				echo. 																											>> %RESULT_FILE%
				echo [현황] 																									>> %RESULT_FILE%
				cacls C:\Inetpub\wwwroot           																				>> %RESULT_FILE%
				ECHO [32-END]                   																				>> %RESULT_FILE%			
				ECHO [W-32]Result : GOOD                   																		>> %RESULT_FILE%
			)
	
		)
	)
	del tmp_32_1.txt
)	
echo.	 																														>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo IIS 데이터 파일 ACL  (cacls C:\Inetpub\wwwroot)                                             								>> %RESULT_FILE%
echo everyone 계정에 "모든권한(F)" 혹은 FILE_WRITE 권한 존재하면 취약                     										>> %RESULT_FILE%
echo Users 계정에 "모든권한(F)" 혹은 FILE_WRITE 권한 존재하면 취약                    											>> %RESULT_FILE%
echo IUSR_[computer] 계정에 "모든권한(F)" 혹은 FILE_WRITE 권한 존재하면 취약                     								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo 해당 계정들이 읽기속성(R)만 부여되었다면 양호                                                         						>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-32 END


rem W-33 START
echo ############################################################ 																>> %RESULT_FILE%
echo [W-33] IIS 미사용 스크립트 매핑 제거  																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [33-START]  																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [33-END]                                                              													>> %RESULT_FILE%
	echo [W-33]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	set param="\.htr\, \.idc\, \.stm\, \.shtm\, \.shtml\, \.printer\, \.htw\, \.ida\, \.idq\,"
	type c:\windows\system32\inetsrv\config\applicationHost.config | findstr /i %param% > tmp_33_1.txt
	type tmp_33_1.txt | findstr /i %param%
	if not errorlevel 1 (
		echo 불필요한 스크립트 매핑이 존재하므로 취약함 																		>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_33_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [33-END] 																											>> %RESULT_FILE%
		echo [W-33]Result : VULNERABLE 																							>> %RESULT_FILE%
	) else (
		echo 불필요한 스크립트 매핑이 존재하지 않으므로 양호함 																	>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		type tmp_33_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [33-END] 																											>> %RESULT_FILE%
		echo [W-33]Result : GOOD 																								>> %RESULT_FILE%	
	)
	del tmp_33_1.txt
)
echo. 																															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo IIS 미사용 스크립트 매핑 제거  (c:\windows\system32\inetsrv\metabase.xml)             										>> %RESULT_FILE%
echo IIS가 사용하지 않는 것                                                                 									>> %RESULT_FILE%
echo .htr                =  웹 기반 암호 재설정 인터넷                                                   						>> %RESULT_FILE%
echo .idc                =  데이터베이스 커넥터                                                           						>> %RESULT_FILE%
echo .stm, .shtm, .shtml =  Server-side Includes                                            									>> %RESULT_FILE%
echo .printer            =  인터넷 인쇄                                                      									>> %RESULT_FILE%
echo .htw, .ida, .idq    =  인덱스 서버                                                       									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo .idc  .printer 매핑의 경우 IIS기본값으로 취약으로 판정                                   									>> %RESULT_FILE%
echo  다음의 매핑들을 개발자와 상의하여 제거할 것을 권고.                                    									>> %RESULT_FILE%
echo. ※ 조치시 마스터 속성과 모든 사이트에 적용을 해야함                                     									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-33 END


rem W-34 START
echo ############################################################ 																>> %RESULT_FILE%
echo [W-34] IIS Exec 명령어 호출 쉘 호출 진단   																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [34-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [34-END]                                                              													>> %RESULT_FILE%
	echo [W-34]Result : N/A                                                             										>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	net start | find "World Wide Web Publishing Service" > NUL
	IF ERRORLEVEL 1 (
		echo.                                                                            										>> %RESULT_FILE%
		ECHO WEB Service Disable                                                         										>> %RESULT_FILE%
		echo.                                                                            										>> %RESULT_FILE%
		ECHO [34-END] >> %RESULT_FILE% & echo [W-34]Result : GOOD 																>> %RESULT_FILE% 
	) else (
		ECHO WEB Service Enable                                                          										>> %RESULT_FILE%
		echo.                                                                            										>> %RESULT_FILE%
		ECHO [IIS Version]						          			                     										>> %RESULT_FILE%
		%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\MajorVersion"   							>> %RESULT_FILE%
		echo.                                                                                       							>> %RESULT_FILE%
		%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\MajorVersion" | findstr "7" > NUL
		IF NOT ERRORLEVEL 1 (
			ECHO [34-END] >> %RESULT_FILE% & echo [W-34]Result : GOOD 															>> %RESULT_FILE% 
		) else (
			echo.                                                                            									>> %RESULT_FILE%
			%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\SSIEnableCmdDirective" 					>> %RESULT_FILE%
			echo.                                                                            									>> %RESULT_FILE%
			%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\SSIEnableCmdDirective" | findstr "1" > NUL
			IF ERRORLEVEL 1 ECHO [34-END] >> %RESULT_FILE% & echo [W-34]Result : GOOD 											>> %RESULT_FILE% 
			IF NOT ERRORLEVEL 1 ECHO [34-END] >> %RESULT_FILE% & echo [W-34]Result : VULNERABLE 								>> %RESULT_FILE% 
			echo.                                                                            									>> %RESULT_FILE%
		) 
	)
)
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo IIS Exec 명령어 호출 쉘 진단                                             													>> %RESULT_FILE%
echo IIS6.0 이상 취약점 없음(Win2003 이상)                                                                 						>> %RESULT_FILE%
echo IIS4.0, 5.0 일경우 아래와 같이 판단.(win2000)                                                   							>> %RESULT_FILE%
echo 레지스트리 값이 없음          =  양호                                                           							>> %RESULT_FILE%
echo SSIEnableCmdDirective 0       =  양호                                                       								>> %RESULT_FILE%
echo SSIEnableCmdDirective 1 이상  =  취약                                                      								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-34 END


rem W-35 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-35] IIS WebDAV 비활성화   																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [35-START] 																												>> %RESULT_FILE%
net start | find "World Wide Web Publishing"         
IF ERRORLEVEL 1 (
	echo IIS 서비스 미구동                                                       												>> %RESULT_FILE%
	echo [35-END]                                                              													>> %RESULT_FILE%
	echo [W-35]Result : N/A                                                             										>> %RESULT_FILE%
) else (
	type c:\windows\system32\inetsrv\metabase.xml | find /i "webdav," | script\sed.exe "s/...//" > tmp_35_1.txt
	type tmp_35_1.txt | findstr "^1"
	if errorlevel 1 (
		echo WebDAV 확장기능이 활성화되지 않음 																					>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_35_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [35-END] 																											>> %RESULT_FILE%
		echo [W-35]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo WebDAV 확장기능이 활성화됨 																						>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_35_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [35-END] 																											>> %RESULT_FILE%
		echo [W-35]Result : VULNERABLE 																							>> %RESULT_FILE% 
	)
	del tmp_35_1.txt
	del iis-check.txt
)
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                            													>> %RESULT_FILE%
echo                                                                  						>> %RESULT_FILE%
echo                                                   							>> %RESULT_FILE%
echo                                                            							>> %RESULT_FILE%
echo                                                        								>> %RESULT_FILE%
echo                                                       								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-35 END


rem W-36 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-36] NetBIOS 바인딩 서비스 구동 점검 																					>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [36-START] 																												>> %RESULT_FILE%
reg query HKLM\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces | find /i "tcpip"> tmp_36_1.txt
for /f "tokens=1" %%a in (tmp_36_1.txt) do reg query "%%a" /s | find /i "NetbiosOptions" >> tmp_36_2.txt
reg query HKLM\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces | find /i "tcpip"> tmp_36_3.txt
type tmp_36_2.txt | findstr "2"
if NOT errorlevel 1 (
	echo 'NetBIOS over TCP/IP 사용 안 함'이 설정되어 있으므로 양호함 															>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_36_3.txt 																											>> %RESULT_FILE%
	type tmp_36_2.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [36-END] 																												>> %RESULT_FILE%
	echo [W-36]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 'NetBIOS over TCP/IP 사용 안 함'이 설정되지 않으므로 취약함 															>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_36_3.txt 																											>> %RESULT_FILE%
	type tmp_36_2.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [36-END] 																												>> %RESULT_FILE%
	echo [W-36]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
del tmp_36_1.txt
del tmp_36_2.txt
del tmp_36_3.txt
echo. 																															>> %RESULT_FILE%
echo.	 																														>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo NetbiosOptions 2       =  양호                                                       										>> %RESULT_FILE%
echo NetbiosOptions 0       =  취약                                                      										>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-36 END


rem W-37 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-37] FTP 서비스 구동 점검 																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [37-START] 																												>> %RESULT_FILE%
net start | find /i "FTP Service"
if errorlevel 1 (
	echo FTP 서비스가 실행중이지 않음 																							>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [37-END] 																												>> %RESULT_FILE%
	echo [W-37]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo FTP 서비스가 실행중임 																									>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net start | find /i "FTP Service" 																							>> %RESULT_FILE%
	echo [37-END] 																												>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [W-37]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
echo. 																															>> %RESULT_FILE%
echo.	 																														>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                                        										>> %RESULT_FILE%
echo                                                       										>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-37 END 


rem W-38 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-38] FTP 디렉토리 접근권한 설정 																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [38-START] 																												>> %RESULT_FILE%
net start | find /i "FTP Service"
if errorlevel 1 (
	echo FTP 서비스가 실행중이지 않으므로 해당사항 없음 																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [38-END] 																												>> %RESULT_FILE%
	echo [W-38]Result : N/A 																									>> %RESULT_FILE%
) else (
	type C:\Windows\System32\inetsrv\config\applicationHost.config | %script%\grep.exe -B 8 "protocol=\"ftp\"" | find /i "physicalPath" > tmp_38_1.txt
	for /f "tokens=5 delims== " %%a in (tmp_38_1.txt) do cacls %%a >> tmp_38_2.txt
	type tmp_38_2.txt | find /i "Everyone"
	if errorlevel 1 (
		echo FTP 디렉토리 접근권한에 Everyone 계정이 존재하지 않으므로 양호함 													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_38_2.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [38-END] 																											>> %RESULT_FILE%
		echo [W-38]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo FTP 디렉토리 접근권한에 Everyone 계정이 존재함으로 취약함 															>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_38_2.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [38-END] 																											>> %RESULT_FILE%
		echo [W-38]Result : VULNERABLE 																							>> %RESULT_FILE% 
	)
	del tmp_38_1.txt
	del tmp_38_2.txt
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo FTP 디렉토리 접근권한 설정                                             													>> %RESULT_FILE%
echo FTP 미구동시 Result : MANUAL 처리                                  														>> %RESULT_FILE%
echo FTP 디폴트 디렉터리만 체크가능 그외는 수동진단 필요함(c:\inetpub\ftproot)                         							>> %RESULT_FILE%
echo ftp홈디렉토리에 Everyone 계정 등록되어있으면 취약 없으면 양호                  											>> %RESULT_FILE%
echo 그외 불필요 사용자가 모든권한(F) 및 Write 권한이 있다면 판단후 취약          												>> %RESULT_FILE%
echo 양호 = Everyone 사용자 삭제, 사용자(Users그룹사용자)의 권한에 쓰기권한 거부                    							>> %RESULT_FILE%
echo 취약 = Everyone 사용자 존재, 사용자(Users그룹사용자)의 권한에 쓰기권한 허용                    							>> %RESULT_FILE%
echo 사용자 계정에 쓰기권한(F) 혹은 FILE_WRITE_DATA권한 존재한다면 취약             											>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-38 END


rem W- 39 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-39] Anonymouse FTP 금지 																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [39-START] 																												>> %RESULT_FILE%
net start | find /i "FTP Service" 
if errorlevel 1 (
	echo FTP 서비스가 실행중이지 않으므로 해당사항 없음 																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [39-END] 																												>> %RESULT_FILE%
	echo [W-39]Result : N/A 																									>> %RESULT_FILE%
) else (	
	type C:\Windows\System32\inetsrv\config\applicationHost.config | %script%\grep.exe -A 8 "protocol=\"ftp\"" | find /i "anonymousAuthentication enabled" > tmp_39_1.txt
	type tmp_39_1.txt | find /i "true"
	if errorlevel 1 (
		echo FTP '익명 연결 허용'이 설정되어 있지 않으므로 양호함 																>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [39-END] 																											>> %RESULT_FILE%
		echo [W-39]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo FTP '익명 연결 허용'이 설정되어 있으므로 취약함 																	>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_39_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [39-END] 																											>> %RESULT_FILE%
		echo [W-39]Result : VULNERABLE 																							>> %RESULT_FILE% 
	)
	del tmp_39_1.txt
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                              													>> %RESULT_FILE%
echo                                   														>> %RESULT_FILE%
echo                          							>> %RESULT_FILE%
echo                   											>> %RESULT_FILE%
echo           												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-39 END


rem W-40 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-40] FTP 접근 제어 설정 																									>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [40-START] 																												>> %RESULT_FILE%
net start | find /i "FTP Service" 
if errorlevel 1 (
	echo FTP 서비스가 실행중이지 않으므로 해당사항 없음 																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [40-END] 																												>> %RESULT_FILE%
	echo [W-40]Result : N/A 																									>> %RESULT_FILE%
) else (	
	type C:\Windows\System32\inetsrv\config\applicationHost.config | %script%\grep.exe -3 "add ipAddress" > tmp_40_1.txt
	type tmp_40_1.txt | find /i "system.ftpServer"
	if errorlevel 1 (
		echo FTP 서비스가 실행중이며, FTP 접근 제어 설정이 적용되어 있지 않으므로 취약함 										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		net start | find /i "FTP Service" 																						>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [40-END] 																											>> %RESULT_FILE%
		echo [W-40]Result : VULNERABLE 																							>> %RESULT_FILE%
	) else (
		type tmp_40_1.txt | %script%\sed.exe -n "/ftpServer/,/ftpServer/p" > tmp_40_2.txt
		echo FTP 서비스가 실행중이며, FTP 접근 제어 설정이 적용되어 있음므로 양호함 											>> %RESULT_FILE% 
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_40_2.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [40-END] 																											>> %RESULT_FILE%
		echo [W-40]Result : GOOD 																								>> %RESULT_FILE% 
	)
)
del tmp_40_1.txt
del tmp_40_2.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                              													>> %RESULT_FILE%
echo                                   														>> %RESULT_FILE%
echo                          							>> %RESULT_FILE%
echo                   											>> %RESULT_FILE%
echo           												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-40 END


rem W-41
echo ############################################################ 																>> %RESULT_FILE%
echo [W-41] DNS Zone Transfer 설정  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [41-START] 																												>> %RESULT_FILE%
net start | find "DNS Server" > NUL
IF ERRORLEVEL 1 (
	ECHO DNS 서비스 미구동 되고 있으므로 해당사항 없음                                                                     		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [41-END]                                                                              									>> %RESULT_FILE%
	ECHO [W-41]Result : N/A                                                           											>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
) else (
	reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries"  | findstr "x0 x1" > nul
	IF ERRORLEVEL 1 echo DNS Zone Transfer 영역전송 설정을 특정서버로만 보내고있어 양호함                						>> %RESULT_FILE%
	IF NOT ERRORLEVEL 1 ECHO DNS Zone Transfer 영역전송 설정제한을 하지 않으므로 취약함                    						>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "DatabaseFile"        				>> %RESULT_FILE%
	reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" 				>> %RESULT_FILE%
	reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecondaryServers"  				>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
	reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries"  | findstr "x0 x1" > nul
	echo [41-END]                                                                              									>> %RESULT_FILE%  
	IF ERRORLEVEL 1 ECHO [W-41]Result : GOOD                                                             						>> %RESULT_FILE%
	IF NOT ERRORLEVEL 1 ECHO [W-41]Result : VULNERABLE                                                         					>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo DNS Zone Transfer 설정                                              														>> %RESULT_FILE%
echo DNS 서비스 미구동시 Result : MANUAL처리                                    												>> %RESULT_FILE%
echo DatabaseFile  = zone 이름                                        															>> %RESULT_FILE%
echo SecureSecondaries = DNS Zone Transfer 영역전송 여부                														>> %RESULT_FILE%
echo AllowUpdate = 0 아무서버로 보냄                                               												>> %RESULT_FILE%
echo AllowUpdate = 1 이름서버 탭에 나열된 서버로만 보냄                           												>> %RESULT_FILE%
echo AllowUpdate = 2 다음서버로만(IP등록해서 사용)                               												>> %RESULT_FILE%
echo SecondaryServers = 영역전송할 서버 내역                                         											>> %RESULT_FILE%
echo AllowUpdate 0,1이면 취약 2이면 양호                                             											>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-41 END


rem W-42 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-42] RDS(RemoteDataServices)제거  																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [42-START] 																												>> %RESULT_FILE%
echo 윈도우 2008 이상이므로 양호함 																								>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [42-END] 									    	 																		>> %RESULT_FILE%
echo [W-42]Result : GOOD					                     																>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                       							>> %RESULT_FILE%
echo                                       						>> %RESULT_FILE%
echo                                        						>> %RESULT_FILE%
echo   														>> %RESULT_FILE%
echo   																								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-42 END


rem W-43 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-43] 최신 서비스팩 적용  																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [43-START] 																												>> %RESULT_FILE%
echo 수동진단 																													>> %RESULT_FILE%
echo																															>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
echo "# systeminfo"                                                                          									>> %RESULT_FILE% 
systeminfo > servicePack.txt 
type servicePack.txt | find "OS Name" 																							>> %RESULT_FILE%
type servicePack.txt | find "OS Version" | find /v "BIOS"                                                          				>> %RESULT_FILE%
echo																															>> %RESULT_FILE%
echo [43-END] 																													>> %RESULT_FILE%
echo [W-43]Result : MANUAL 																										>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                       							>> %RESULT_FILE%
echo                                       						>> %RESULT_FILE%
echo                                        						>> %RESULT_FILE%
echo   														>> %RESULT_FILE%
echo   																								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-43 END


rem W-44 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-44] 터미널 서비스 암호화 수준 설정  																					>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [44-START] 																												>> %RESULT_FILE%
NET START | FIND "Terminal Service" > NUL
IF NOT ERRORLEVEL 1 ( 
	echo 터미널 서비스가 중지되었으므로 양호함                                                   								>> %RESULT_FILE%    
	echo. 																														>> %RESULT_FILE%
	echo [44-END]                                                                             									>> %RESULT_FILE%
	ECHO [W-44]Result : GOOD                                              														>> %RESULT_FILE%
) else (
	echo 터미널 서비스가 구동중                                              													>> %RESULT_FILE%
	echo Terminal Service Enabled                                                                								>> %RESULT_FILE%
	reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel | FIND "1"
	IF ERRORLEVEL 1 echo 터미널 암호화 수준이 낮지 않으므로 양호함                               								>> %RESULT_FILE%
	IF NOT ERRORLEVEL 1 echo 터미널 암호화 수준이 낮으므로 취약함                               								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel | FIND /i "minencryptionlevel" >> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
	echo [44-END]                                                                              									>> %RESULT_FILE%
	reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel" | FIND "1"
	IF ERRORLEVEL 1 echo [W-44]Result : GOOD                                                              						>> %RESULT_FILE%
	IF NOT ERRORLEVEL 1 echo [W-44]Result : VULNERABLE                                                          				>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                       									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 터미널 서비스 암호화 수준 설정                                                                								>> %RESULT_FILE%
echo 터미널 서비스 미구동중일시 양호 판정                                   													>> %RESULT_FILE%
echo MinEncryptionLevel=0 (암호화 수준 낮음)                            														>> %RESULT_FILE%
echo MinEncryptionLevel=1 (암호화 수준 클라이언트 호환 가능)                 													>> %RESULT_FILE%
echo MinEncryptionLevel=2 (암호화 수준 높음)                              														>> %RESULT_FILE%                                                                  
echo MinEncryptionLevel=4 (암호화 수준 FIPS규격)                             													>> %RESULT_FILE%
echo 숫자가 높을수록 암호화 강도가 높음 0일시 취약 0이상은 양호                													>> %RESULT_FILE%
echo Windows 2003 은  MinEncryptionLevel=1 권장                                													>> %RESULT_FILE%
echo ------------------------------------------------------------                            									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-44-END


rem W-45-Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-45] IIS 웹서비스 정보 숨김  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [45-START] 																												>> %RESULT_FILE%
echo 아래 에러페이지 설정을 바탕으로 수동점검 																					>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
type c:\windows\system32\inetsrv\config\applicationHost.config | find /i "error statusCode" 									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [45-END] 																													>> %RESULT_FILE%
echo [W-45]Result : MANUAL 																										>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                       							>> %RESULT_FILE%
echo                                       						>> %RESULT_FILE%
echo                                        						>> %RESULT_FILE%
echo   														>> %RESULT_FILE%
echo   																								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
rem W-45-END


rem W-46 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-46] SNMP 서비스 구동 점검  																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [46-START] 																												>> %RESULT_FILE%
net start | find "SNMP Service" 
if errorlevel 1 (
	echo SNMP 서비스가 실행중이지 않으므로 양호함 																				>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [46-END] 																												>> %RESULT_FILE%
	echo [W-46]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo SNMP 서비스가 실행되고 있으므로 취약함 																				>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net start | find "SNMP Service" 																							>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [46-END] 																												>> %RESULT_FILE%
	echo [W-46]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                              													>> %RESULT_FILE%
echo                                   														>> %RESULT_FILE%
echo                          							>> %RESULT_FILE%
echo                   											>> %RESULT_FILE%
echo           												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-46 END


rem W-47 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-47] SNMP 서비스 커뮤니티스트링의 복잡성 설정	  																		>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [47-START] 																												>> %RESULT_FILE%
net start | find "SNMP Service" 
if errorlevel 1 (
	echo SNMP 서비스가 실행중이지 않음으로 해당사항 없음 																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [47-END] 																												>> %RESULT_FILE%
	echo [W-47]Result : N/A 																									>> %RESULT_FILE%
) else (
	%script%\reg.exe query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" | find "REG_DWORD" > tmp_47_1.txt 
	type tmp_47_1.txt | find "REG_DWORD"
	if errorlevel 1 (
		echo SNMP 서비스가 실행중이며, Community String이 설정되어 있지 않으므로 취약함 										>> %RESULT_FILE%
		echo.																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		net start | find "SNMP Service" 																						>> %RESULT_FILE% 
		echo. 																													>> %RESULT_FILE%
		echo [47-END] 																											>> %RESULT_FILE%
		echo [W-47]Result : VULNERABLE 																							>> %RESULT_FILE%
	)
	type tmp_47_1.txt | find "REG_DWORD" | findstr "8 16"
	if not errorlevel 1 (
		echo Community String에 읽기 이상의 권한이 부여되어 있으므로 취약함 													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_47_1.txt | find "REG_DWORD" | findstr "8 16" 																	>> %RESULT_FILE%
	)
	type tmp_47_1.txt | find "REG_DWORD" | findstr /i "public private"
	if not errorlevel 1 (
		echo Community String이 디폴트 값으로 설정되어 있으므로 취약함 															>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities 											>> %RESULT_FILE% 
		type tmp_47_1.txt | find "REG_DWORD" | findstr /i "public private" 														>> %RESULT_FILE%
	) else (
		echo Community String이 읽기전용으로 임의의 값으로 설정되어 있음으로 양호함 											>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities 											>> %RESULT_FILE% 
		type tmp_47_1.txt | find "REG_DWORD" 																					>> %RESULT_FILE%
	)
	echo. 																														>> %RESULT_FILE%
	echo [47-END] 																												>> %RESULT_FILE%
	echo [W-47]Result : MANUAL 																									>> %RESULT_FILE%
	echo 현행 값 확인 후 취약 양호 판단																							>> %RESULT_FILE%
)
del tmp_47_1.txt
echo. 																															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo SNMP 서비스 커뮤니티스트링의 복잡성 설정                                             										>> %RESULT_FILE%
echo ValidCommunities = public, private 값이 존재하면 취약                           											>> %RESULT_FILE% 
echo ValidCommunities = 1 (속성 없음)                            																>> %RESULT_FILE%
echo ValidCommunities = 2 (알림 속성)                                                       									>> %RESULT_FILE%
echo ValidCommunities = 4 (읽기 전용속성)              																			>> %RESULT_FILE%
echo ValidCommunities = 8 (읽기,쓰기속성)               																		>> %RESULT_FILE%
echo ValidCommunities = 16 (읽기,만들기속성)               																		>> %RESULT_FILE%
echo 8 또는 16 (쓰기, 만들기 속성이 포함되어있다면 판단후 조치)                													>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-47 END


rem W-48 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-48] SNMP Access control 설정	  																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [48-START] 																												>> %RESULT_FILE%
net start | find "SNMP Service" 
if errorlevel 1 (
	echo SNMP 서비스가 실행중이지 않으므로 해당사항 없음																		>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [48-END] 																												>> %RESULT_FILE%
	echo [W-48]Result : N/A 																									>> %RESULT_FILE%
) else (
	%script%\reg.exe query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" | find "REG_SZ" > tmp_48_1.txt
	type tmp_48_1.txt | find "REG_SZ"
	if not errorlevel 1 (
		echo SNMP 서비스가 특정 호스트로부터 SNMP 패킷을 받아들이도록 설정되어 있으므로 양호함 									>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers 											>> %RESULT_FILE%
		type tmp_48_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [48-END] 																											>> %RESULT_FILE%
		echo [W-48]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo SNMP 서비스가 특정 호스트로부터 SNMP 패킷을 받아들이도록 설정되지 않으므로 취약함 									>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		net start | find "SNMP Service" 																						>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [48-END] 																											>> %RESULT_FILE%
		echo [W-48]Result : VULNERABLE 																							>> %RESULT_FILE% 
	)
	del tmp_48_1.txt
)
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                              													>> %RESULT_FILE%
echo                                   														>> %RESULT_FILE%
echo                          							>> %RESULT_FILE%
echo                   											>> %RESULT_FILE%
echo           												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-48 END


rem W-49 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-49] DNS 서비스 구동 점검 	  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [49-START] 																												>> %RESULT_FILE%
net start | find /i "DNS Server"
if errorlevel 1 (
	echo DNS 서비스가 실행중이지 않으므로 양호함 																				>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [49-END] 																												>> %RESULT_FILE%
	echo [W-49]Result : GOOD 																									>> %RESULT_FILE%
) else (
	reg.exe query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "AllowUpdate" > tmp_49_1.txt
	type tmp_49_1.txt | find "0"
	if not errorlevel 1 (
		echo DNS 서비스가 실행중이며 동적 업데이트가 허용되지 않으므로 양호함 													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_49_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [49-END] 																											>> %RESULT_FILE%
		echo [W-49]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo DNS 서비스가 실행중이며 동적 업데이트가 허용되어 있으므로 취약함 													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type tmp_49_1.txt 																										>> %RESULT_FILE%
		echo [49-END] 																											>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [W-49]Result : VULNERABLE 																							>> %RESULT_FILE% 
	)
	del tmp_49_1.txt
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo DNS 서비스 구동 점검                                              															>> %RESULT_FILE%
echo DNS 서비스 미구동시 양호                                    																>> %RESULT_FILE%
echo AllowUpdate = 동적업데이트 사용여부                                          												>> %RESULT_FILE%
echo AllowUpdate = 0 없음(사용안함)                                                												>> %RESULT_FILE%
echo AllowUpdate = 1 보안되지 않음및 보안됨(사용함)                                      										>> %RESULT_FILE%
echo AllowUpdate 0이면 양호 1이면 취약                                             												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-49 END


rem W-50 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-50] HTTP/FTP/SMTP 배너 차단 	  																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [50-START] 																												>> %RESULT_FILE%
echo [HTTP]                                                                          											>> %RESULT_FILE%
echo IIS7 해당 사항 없음                                                          												>> %RESULT_FILE%
echo.                                                                           													>> %RESULT_FILE%
echo [FTP]                                                                          											>> %RESULT_FILE%
echo 양호기준 : messages bannerMessage="배너 구문" suppressDefaultBanner="true"         										>> %RESULT_FILE%
echo type C:\Windows\System32\inetsrv\config\applicationHost.config | find "messages bannerMessage" 							>> %RESULT_FILE%
type C:\Windows\System32\inetsrv\config\applicationHost.config | find "messages bannerMessage" 									>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo [SMTP]                                                                          											>> %RESULT_FILE%
echo 양호기준 : ConnectResponse=배너 구문        																				>> %RESULT_FILE%
echo type C:\Windows\System32\inetsrv\MetaBase.xml | find "ConnectResponse" 													>> %RESULT_FILE%
echo 서비스 실행 확인 netstat -an | find ":25"																					>> %RESULT_FILE%
netstat -an | find ":25" 																										>> %RESULT_FILE%
type C:\Windows\System32\inetsrv\MetaBase.xml | find "ConnectResponse" 															>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%
echo [50-END] 																													>> %RESULT_FILE%
echo [W-50]Result : MANUAL 																										>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                              													>> %RESULT_FILE%
echo                                   														>> %RESULT_FILE%
echo                          							>> %RESULT_FILE%
echo                   											>> %RESULT_FILE%
echo           												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-50 END


rem W-51 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-51] Telnet 보안 설정 	  																								>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [51-START] 																												>> %RESULT_FILE%
net start | find /i "Telnet"
if errorlevel 1 (
	echo Telnet 서비스가 실행중이지 않으므로 양호함 																			>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [51-END] 																												>> %RESULT_FILE%
	echo [W-51]Result : GOOD 																									>> %RESULT_FILE%
) else (
	%script%\reg.exe query "HKLM\Software\Microsoft\TelnetServer\1.0\SecurityMechanism" > tmp_51_1.txt
	type tmp_51_1.txt | find "2"
	if not errorlevel 1 (
		echo Telnet 서비스가 실행중이며, NTLM 인증을 사용함으로 양호함 															>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo HKLM\Software\Microsoft\TelnetServer\1.0\SecurityMechanism 														>> %RESULT_FILE%
		type tmp_51_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [51-END] 																											>> %RESULT_FILE%
		echo [W-51]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo Telnet 서비스가 실행중이며, NTLM 인증을 사용하지 않으므로 취약함 													>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo HKLM\Software\Microsoft\TelnetServer\1.0\SecurityMechanism 														>> %RESULT_FILE%
		type tmp_51_1.txt 																										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [51-END] 																											>> %RESULT_FILE%
		echo [W-51]Result : VULNERABLE 																							>> %RESULT_FILE% 
	)
	del tmp_51_1.txt
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo Telnet 보안 설정                                              																>> %RESULT_FILE%
echo Telnet 서비스 미구동시 양호 처리                                    														>> %RESULT_FILE%
echo SecurityMechanism = TELNET 서비스 인증방식설정                 															>> %RESULT_FILE%
echo SecurityMechanism = 0 passwd 인증방식                                               										>> %RESULT_FILE%
echo SecurityMechanism = 1 passwd 인증방식                            															>> %RESULT_FILE%
echo SecurityMechanism = 2 (passwd 인증 방식을 제외하고 NTLM 인증방식 만 사용)                               					>> %RESULT_FILE%
echo SecurityMechanism 2이면 양호 그외는취약(tlntadmn config 명령으로 확인가능)                                            		>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.      																														>> %RESULT_FILE%
echo.       																													>> %RESULT_FILE%
rem W-51 END


rem W-52 Start 
echo ############################################################ 		>> %RESULT_FILE%
echo [W-52] 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브 제거 			>> %RESULT_FILE%
echo ############################################################ 		>> %RESULT_FILE%
echo [52-START] 								>> %RESULT_FILE%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources" | find /i "reg_sz"    
IF NOT ERRORLEVEL 1 goto FOUND_32BIT
reg query "HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" | find /i "reg_sz" 
IF NOT ERRORLEVEL 1 goto FOUND_64BIT

ECHO ODBC Data Sources 존재하지 않으므로 양호함 					>> %RESULT_FILE%
echo. 										>> %RESULT_FILE%
echo [현황] 									>> %RESULT_FILE%
echo -----32비트 ODBC리스트------ 						>> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources" | find /i "reg_sz" >> %RESULT_FILE%
echo -----64비트 ODBC리스트------ 						>> %RESULT_FILE%
reg query "HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" | find /i "reg_sz" 	>> %RESULT_FILE%
echo. 										>> %RESULT_FILE%
echo [52-END]				 					>> %RESULT_FILE%
echo [W-52]Result : GOOD 							>> %RESULT_FILE%
goto END

:FOUND_32BIT
:FOUND_64BIT
ECHO ODBC Data Sources 존재(사용여부 인터뷰) 					>> %RESULT_FILE%
echo. 										>> %RESULT_FILE%
echo [현황] 									>> %RESULT_FILE%
echo -----32비트 ODBC리스트------ 						>> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources" | find /i "reg_sz" >> %RESULT_FILE%
echo -----64비트 ODBC리스트------ 						>> %RESULT_FILE%
reg query "HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" | find /i "reg_sz" 	>> %RESULT_FILE%
echo.										>> %RESULT_FILE%
echo [52-END]									>> %RESULT_FILE%
echo [W-52]Result : VULNERABLE 							>> %RESULT_FILE%
goto END

:END
echo. 										>> %RESULT_FILE%
echo. 										>> %RESULT_FILE%
echo ---------- [참고] --------------------------- 				>> %RESULT_FILE%
echo 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브 제거 				>> %RESULT_FILE%
echo 사용하지 않는 불필요한 ODBC 데이터 소스는 제거. 사용할 경우 양호 		>> %RESULT_FILE%
echo 담당자와 인터뷰 필요 							>> %RESULT_FILE%
echo 아무것도 존재하지 않으면 양호처리 						>> %RESULT_FILE%
echo ---------------------------------------------- 				>> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%
rem W-52 END


rem W-53 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-53] 원격터미널 접속 타임아웃 설정	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [53-START] 																												>> %RESULT_FILE%
echo 수동진단이 필요함                                                                                        					>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
echo "Win7 이전" 
reg query "HKLM\SYSTEM\ControlSet001\Control\Terminal Server\WinStations\RDP-Tcp" /v fEnableWinStation | find "fEnableWinStation" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" | find  "MaxDisconnectionTime" | find /V "fInherit" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" | find  "MaxConnectionTime" | find /V "fInherit" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" | find  "MaxIdleTime" | find /V "fInherit" >> %RESULT_FILE%
echo ""
echo "Win10 이후"
reg query "HKLM\SYSTEM\ControlSet001\Control\Terminal Server\WinStations\RDP-Tcp" /v fEnableWinStation | find "fEnableWinStation" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" | find  "MaxDisconnectionTime" | find /V "fInherit" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" | find  "MaxConnectionTime" | find /V "fInherit" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" | find  "MaxIdleTime" | find /V "fInherit" >> %RESULT_FILE%
echo ""
echo [53-END] 									     >> %RESULT_FILE%
echo [W-53]Result : MANUAL									     >> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 원격터미널 접속 타임아웃 설정																								>> %RESULT_FILE%
echo 양호 = 원격제어(원격접속)시 Timeout 을 제어설정을 했을시.  ( 숫자값이 나오면 양호)              							>> %RESULT_FILE%
echo 취약 = 원격제어(원격접속)시 Timeout 을 제어설정을 안했을시.( 0값이 나오면 취약)                							>> %RESULT_FILE%
echo.시간값 1분 = 60000  10분 = 600000  15분 = 900000  1시간 = 3600000                         									>> %RESULT_FILE%     
echo MaxDisconnectionTime = 연결 끊킨 세션 끝내기(연결이 끊어진 사용자는 세션은 붙어있으나 이 시간이 지나면 세션을 끊어버린다.) >> %RESULT_FILE%
echo MaxConnectionTime = 활성 세션 제한(접속한 사용자는 어떤 업무를 하던간에 이시간이 지나면 연결이 끊어지게된다.)         		>> %RESULT_FILE%
echo MaxIdleTime = 유휴 세션 제한(서버에 연결해서 아무런 행동을 하지 않을시 값을 초과하는 경우 끊어지게 된다)                   >> %RESULT_FILE%
echo 정해진 기준값 없으므로 환경에 따라 설정 권고                                             									>> %RESULT_FILE%
echo GUI = 시작-관리도구-원격데스크톱 서비스-원격 데스크톱 세션 호스트 구성-RDP-TCP 더블클릭-       							>> %RESULT_FILE%
echo 세션 텝창-사용자설정무시 항목체크                                                         									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-53 END


rem W-54 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-54] 예약된 작업에 의심스러운 명령이 등록되어 있는지 점검	 	  														>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [54-START] 																												>> %RESULT_FILE%
dir C:\WINDOWS\Tasks | find "job" > tmp_54_1.txt
type tmp_54_1.txt | find "job"
if errorlevel 1 (
	echo 예약된 작업이 존재하지 않으므로 양호함 																				>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [54-END] 																												>> %RESULT_FILE%
	echo [W-54]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 예약된 작업이 존재하므로 취약함 																						>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_54_1.txt 																											>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [54-END] 																												>> %RESULT_FILE%
	echo [W-54]Result : MANUAL 																									>> %RESULT_FILE% 
)
del tmp_54_1.txt
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                              													>> %RESULT_FILE%
echo                                   														>> %RESULT_FILE%
echo                          							>> %RESULT_FILE%
echo                   											>> %RESULT_FILE%
echo           												>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-54 END


rem W-55 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-55] 최신 HOT FIX 적용	 	  																							>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [55-START] 																												>> %RESULT_FILE%

echo [현황] 																												>> %RESULT_FILE%
	
wmic QFE Get HotFixID,InstalledOn | find /v ""		>> %RESULT_FILE%

echo [55-END] 																													>> %RESULT_FILE%
echo [W-55]Result : MANUAL 																										>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-55 END


rem W-56 Start
echo ############################################################ 																>> %RESULT_FILE%
echo [W-56] 백신 업데이트 여부	 	 	 																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [56-START] 																												>> %RESULT_FILE%
echo 아래 내용을 바탕으로 수동점검 																								>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
net start | find /i "Alyac"
if not errorlevel 1 reg query HKLM\SOFTWARE\ESTsoft\ALYac /s | find /i"dbUpdateDate" 											>> %RESULT_FILE%
net start | findstr /i "V3 Ahnlab"
if not errorlevel 1 reg query HKLM\SOFTWARE\AhnLab /s | find /i "V3EngineDate" 													>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [56-END] 																													>> %RESULT_FILE%
echo [W-56]Result : MANUAL 																										>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-56 END


rem W-57 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-57] 정책에 따른 시스템 로깅 설정 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [57-START] 																												>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
%script%\auditpol  | findstr "Logon Policy Directory Management Privilege"       > tmp_57_1.txt
type tmp_57_1.txt                                                           													>> %RESULT_FILE%
type tmp_57_1.txt | Findstr "Logon Policy" | Find /V "Success and Failure"   > tmp_57_2.txt
type tmp_57_1.txt | Findstr "Directory Management Privilege" | Find /V "Failure"    >> tmp_57_2.txt
echo.                                                                            												>> %RESULT_FILE%
echo [57-END] 																													>> %RESULT_FILE% 
echo [W-57]Result : MANUAL 																										>> %RESULT_FILE%
del tmp_57_1.txt
del tmp_57_2.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo System                    = 시스템, 이벤트 감사(성공/실패)                                   								>> %RESULT_FILE%
echo Logon                     = 로그온, 이벤트 감사          (성공/실패)                         								>> %RESULT_FILE%
echo Object Access             = 개채, 액세스 감사  (해당없음)                                    								>> %RESULT_FILE%
echo Privilege Use             = 권한 사용 감사               (해당 없음)                              								>> %RESULT_FILE%
echo Process Tracking          = 프로세스 추적 감사 (해당없음)                                    								>> %RESULT_FILE%
echo Policy Change             = 정책 변경 감사     (성공)                                    								>> %RESULT_FILE%
echo Account Management        = 계정 관리 감사               (성공)                              								>> %RESULT_FILE%
echo Directory Service Access  = 디렉터리 서비스 액세스 감사  (성공)                              								>> %RESULT_FILE%
echo Account Logon             = 계정 로그온 이벤트 감사      (성공)                         								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-57 END


rem W-58 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-58] 로그의 정기적 검토 및 보고	 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [58-START] 																												>> %RESULT_FILE%
echo 인터뷰 점검 항목 																											>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [58-END] 																													>> %RESULT_FILE%
echo [W-58]Result : MANUAL 																										>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-58 END


rem W-59 Start, 개선필요 업데이트 예정
echo ############################################################ 																>> %RESULT_FILE%
echo [W-59] 원격으로 액세스할 수 있는 레지스트리 경로		 	 	  															>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [59-START] 																												>> %RESULT_FILE%
net start | find /i "Remote Registry"
IF ERRORLEVEL 1 echo Remote Registry 서비스가 중지되어있으므로 양호함                 											>> %RESULT_FILE%
IF NOT ERRORLEVEL 1 echo Remote Registry 서비스가 구동되어있으므로 취약함                 										>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
net start | find /i "Remote Registry"                                                   										>> %RESULT_FILE%
echo 서비스 시작유형 :                                                                       									>> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RemoteRegistry\Start"        									>> %RESULT_FILE%
echo [59-END]                                                                              										>> %RESULT_FILE%
echo [W-59]Result : MANUAL                                                         												>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 서비스 시작유형(재부팅시 서비스 구동여부)                                             	 									>> %RESULT_FILE%
echo 자동(재부팅시 시작됨)       -  2                                       													>> %RESULT_FILE%
echo 수동(재부팅시 수동)         -  3                                                                    						>> %RESULT_FILE%
echo 사용안함(재부팅시 중지됨)   -  4                                                                							>> %RESULT_FILE%
echo 값이 4(재부팅시에도 중지)를 권장                                                       									>> %RESULT_FILE%
echo 서비스 시작/중지 여부와 시작유형값 판단하여 판정                                       									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-59 END


rem W-60 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-60] 이벤트 로그 관리 설정		 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [60-START] 																												>> %RESULT_FILE%
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Application" | find "MaxSize" | find /V "fInherit"	     > tmp_60_1.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Security" | find "MaxSize" | find /V "fInherit"		     > tmp_60_2.txt
reg query "HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\System" | find "MaxSize" | find /V "fInherit"		     > tmp_60_3.txt
FOR /f "tokens=3" %%p IN (tmp_60_1.txt) do set /a tmp1=%%p
IF NOT %tmp1% GEQ 10485760 echo bad 	>> tmp_60_1.txt
FOR /f "tokens=3" %%p IN (tmp_60_2.txt) do set /a tmp2=%%p
IF NOT %tmp2% GEQ 10485760 echo bad >> tmp_60_2.txt
FOR /f "tokens=3" %%p IN (tmp_60_3.txt) do set /a tmp3=%%p
IF NOT %tmp3% GEQ 10485760 echo bad >> tmp_60_3.txt
type tmp_60_1.txt | find "bad"
IF ERRORLEVEL 1 (
	type tmp_60_2.txt | find "bad"
	IF ERRORLEVEL 1 (
		type tmp_60_3.txt| find "bad"
		IF ERRORLEVEL 1 (
			echo 로그크기가 10MB 이상이며 로그가 꽉 차면 로그보관으로 설정되어있으므로 양호함                     	 				>> %RESULT_FILE%
			echo. 																												>> %RESULT_FILE%
			echo [현황] 																										>> %RESULT_FILE%
			echo [Application log Size]                                                                  						>> %RESULT_FILE%
			echo %tmp1%	    															>> %RESULT_FILE%
			echo [Security log  Size]                                                                    						>> %RESULT_FILE%
			echo %tmp2%	    															>> %RESULT_FILE%
			echo [System log  Size]                                                                      						>> %RESULT_FILE%
			echo %tmp3%	    															>> %RESULT_FILE%
			echo.                                                                                        						>> %RESULT_FILE%
			echo [60-END]                                                                             							>> %RESULT_FILE%
			echo [W-60]Result : GOOD                                                                             				>> %RESULT_FILE%
		)
	) 
) else (
	echo 로그 크기 및 보관일 설정이 권장수준으로 설정되어있지 않으므로 취약함                     								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	echo [Application log Size]                                                                  								>> %RESULT_FILE%
	echo %tmp1%	    																	>> %RESULT_FILE%
	echo [Security log  Size]                                                                    								>> %RESULT_FILE%
	echo %tmp2%	    																	>> %RESULT_FILE%
	echo [System log  Size]                                                                      								>> %RESULT_FILE%
	echo %tmp3%	    																	>> %RESULT_FILE%
	echo.                                                                                        								>> %RESULT_FILE%
	echo [60-END]                                                                               								>> %RESULT_FILE%
	echo [W-60]Result : VULNERABLE                                                                             					>> %RESULT_FILE%
)
set tmp1=
set tmp2=
set tmp3=
del tmp_60_1.txt
del tmp_60_2.txt
del tmp_60_3.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 이벤트 로그 관리 설정                                   																	>> %RESULT_FILE%
echo Application log Size        =  응용프로그램 최대로그크기                        											>> %RESULT_FILE%
echo Security log  Size          =  보안 최대로그크기                                   										>> %RESULT_FILE%
echo System log  Size            =  시스템 최대 로그크기                                										>> %RESULT_FILE%
echo AutoBackupLogFiles          =  0 응용프로그램 최대로그크기 도달시 오래된 이벤트 덮어씀 - 취약  							>> %RESULT_FILE%
echo AutoBackupLogFiles          =  1 응용프로그램 최대로그크기 도달시 오래된 이벤트 덮어쓰지않음 -양호     					>> %RESULT_FILE%
echo 크기 권장사항        = 10240KB 이상 양호 (레지스트리표시값 = 10485760)                              						>> %RESULT_FILE%
echo 덮어쓸 일수 변경위치 = HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System\Retention 에 값입력            >> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-60 END


rem W-61 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-61] 원격에서 이벤트 로그 파일 접근 차단		 	 	  																	>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [61-START] 																												>> %RESULT_FILE%
cacls %systemroot%\system32\logfiles                                                         > tmp_61_1.txt
cacls %systemroot%\system32\config                                                           >> tmp_61_1.txt
TYPE tmp_61_1.txt | findstr /I "everyone" > nul
IF ERRORLEVEL 1 (
	ECHO 이벤트 로그 파일에 everyone 권한이 존재하지 않으므로 양호함 															>> %RESULT_FILE% 
	echo. 																														>> %RESULT_FILE% 
	echo [현황] 																												>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE% 
	echo [61-END] 																												>> %RESULT_FILE%
	ECHO [W-61]Result : GOOD 																									>> %RESULT_FILE%
) else (
	ECHO 이벤트 로그 파일에 everyone 권한이 존재함으로 취약함  																	>> %RESULT_FILE% 
	echo. 																														>> %RESULT_FILE% 
	echo [현황] 																												>> %RESULT_FILE%
	TYPE tmp_61_1.txt 																											>> %RESULT_FILE%
	echo 																														>> %RESULT_FILE% 
	echo [61-END] 	 																											>> %RESULT_FILE%
	ECHO [W-61]Result : VULNERABLE 																								>> %RESULT_FILE%
)
del tmp_61_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 원격에서 이벤트 로그 파일 접근 차단                                   														>> %RESULT_FILE%
echo windows\system32\logfiles   =  OS 시스템 로그 위치                        													>> %RESULT_FILE%
echo windows\system32\config     =  OS 시스템 로그 위치                                   										>> %RESULT_FILE%
echo 해당 디렉터리에 everyone 계정이 존재하면 취약 없으면 양호                                									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-61 END


rem W-62 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-62] 백신 프로그램 설치	 	 	  																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [62-START] 																												>> %RESULT_FILE%
net start | findstr /i "AlYac Hauri V3 Ahnlab Symantec" 
if not errorlevel 1 (
	echo 백신이 설치되어 있으므로 양호함 																						>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	net start | findstr /i "AlYac Hauri V3 Ahnlab Symantec" 																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [62-END] 																												>> %RESULT_FILE%
	echo [W-62]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 백신이 설치되어 있지 않으므로 취약함 																					>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [62-END] 																												>> %RESULT_FILE%
	echo [W-62]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
echo.                                                                                        									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-62 END


rem W-63 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-63] SAM 파일 접근통제 	 	 	  																						>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [63-START] 																												>> %RESULT_FILE%
cacls %systemroot%\system32\config\SAM | findstr /v "Administrator SYSTEM" | findstr "\ :" > NUL
IF ERRORLEVEL 1 (
	ECHO SAM 디렉터리에 SYSTEM 및 관리자권한이외 권한이 존재하지 않으므로 양호함            									>> %RESULT_FILE%  
	echo. 																														>> %RESULT_FILE%  
	echo [현황] 																												>> %RESULT_FILE%
	cacls %systemroot%\system32\config\SAM							     														>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [63-END] 																												>> %RESULT_FILE%
	ECHO [W-63]Result : GOOD                                                             										>> %RESULT_FILE%
) else (
	ECHO SAM 디렉터리에 SYSTEM 및 관리자권한이외 권한이 존재함으로 취약함                                                       >> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	cacls %systemroot%\system32\config\SAM							     														>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [63-END] 																												>> %RESULT_FILE%
	ECHO [W-63]Result : VULNERABLE   																							>> %RESULT_FILE%
)
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo SAM 파일 접근통제                                                                        									>> %RESULT_FILE%
echo windows\system32\config\SAM 파일에 SYSTEM, Administrators                                									>> %RESULT_FILE%
echo 을 제외한 권한이 들어가있다면 취약                                                                    						>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-63 END


rem W-64 Start 
echo ############################################################ >> %RESULT_FILE%
echo [W-64] 화면보호기 설정 >> %RESULT_FILE%
echo ############################################################ >> %RESULT_FILE%
echo [64-START] >> %RESULT_FILE%
%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaveActive" | find "1"
if errorlevel 1 goto VULNERABLE

%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaverIsSecure" | find "1"
if errorlevel 1 goto VULNERABLE

%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaveTimeOut" > tmp_64_1.txt
for /f "tokens=3" %%a in (tmp_64_1.txt) do set var=%%a
if %var% LSS 601 (
    goto GOOD
) else (
    goto VULNERABLE
)

:GOOD
echo 화면보호기 설정이 정책에 맞게 설정되어 있으므로 양호함 >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo [현황] >> %RESULT_FILE%
%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaveActive" >> %RESULT_FILE%
%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaverIsSecure" >> %RESULT_FILE%
%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaveTimeOut" >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo [64-END] >> %RESULT_FILE%
echo [W-64]Result : GOOD >> %RESULT_FILE%
goto END

:VULNERABLE
echo 화면보호기 설정이 정책에 맞지 않으므로 취약함 >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo [현황] >> %RESULT_FILE%
%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaveActive" >> %RESULT_FILE%
%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaverIsSecure" >> %RESULT_FILE%
%script%\reg.exe query "HKCU\Control Panel\Desktop\ScreenSaveTimeOut" >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo [64-END] >> %RESULT_FILE%
echo [W-64]Result : VULNERABLE >> %RESULT_FILE%
goto END

:END
del tmp_64_1.txt
echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo ---------- [참고] --------------------------- >> %RESULT_FILE%
echo ScreenSaveActive = 화면보호기 작동유무 >> %RESULT_FILE%
echo ScreenSaverIsSecure = 데이터 값이 0, 1에 상관없이 무조건 다시시작할때 암호로 보호 >> %RESULT_FILE%
echo ScreenSaveTimeOut = 대기 시간 설정 초 단위 >> %RESULT_FILE%
echo ---------------------------------------------- >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%
rem W-64 END



rem W-65 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-65] 로그온 하지 않고 시스템 종료 허용 	 	 	  																		>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [65-START] 																												>> %RESULT_FILE%
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ShutdownWithoutLogon" > tmp_65_1.txt
find "0x1" tmp_65_1.txt > NUL
IF ERRORLEVEL 1 (
	ECHO 로그인을 하지 않고 시스템 종료를 허용하지 않으므로 양호함 																>> %RESULT_FILE%
	echo.  																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ShutdownWithoutLogon" | find "ShutdownWithoutLogon"	>> %RESULT_FILE%
	echo.  																														>> %RESULT_FILE%
	echo [65-END] 																												>> %RESULT_FILE%
	ECHO [W-65]Result : GOOD 																									>> %RESULT_FILE%
) else (                                                            
	ECHO 로그인을 하지 않고 시스템 종료가 가능함으로 취약함  																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE% 
	echo [현황] 																												>> %RESULT_FILE%
	reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ShutdownWithoutLogon" | find "ShutdownWithoutLogon" >> %RESULT_FILE%
	echo 																														>> %RESULT_FILE%
	echo [65-END] 																												>> %RESULT_FILE%
	ECHO [W-65]Result : VULNERABLE 																								>> %RESULT_FILE%
)                                                                             
del tmp_65_1.txt
echo.                                                                                        									>> %RESULT_FILE%                                                                                          
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 로그온 하지 않고 시스템 종료 허용                                                                        					>> %RESULT_FILE%
echo ShutdownWithoutLogon = 0 (로그온하지 않고 시스템을 종료할수 없음)                                                  		>> %RESULT_FILE%
echo ShutdownWithoutLogon = 1 (로그온하지 않고 시스템 종료가 가능함)                           									>> %RESULT_FILE%
echo 0이면 양호 1이면 취약함                                                                   									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-65 END


rem W-66 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-66] 원격 시스템에서 강제로 시스템 강제 종료 차단 	 	 	  															>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [66-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | Find /I "SeRemoteShutdownPrivilege"                         > tmp_66_1.txt
For /F "tokens=1-10 delims=," %%a IN (tmp_66_1.txt) DO @echo %%a > tmp_66_2.txt | @echo %%b >> tmp_66_2.txt | @echo %%c >> tmp_66_2.txt | @echo %%d >> tmp_66_2.txt | @echo %%e >> tmp_66_2.txt | @echo %%f >> tmp_66_2.txt | @echo %%g >> tmp_66_2.txt | @echo %%h >> tmp_66_2.txt | @echo %%i >> tmp_66_2.txt | @echo %%j >> tmp_66_2.txt
type tmp_66_2.txt | Findstr /v "*S-1-5-32-544" | Find /v "ECHO" | Findstr /I /R [a-z] >NUL  
IF ERRORLEVEL 1 (
	echo 원격 시스템에서 시스템종료는 Administrators 만 가능함으로 양호함        												>> %RESULT_FILE% 
	echo. 																														>> %RESULT_FILE% 
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "SeRemoteShutdownPrivilege"                         								>> %RESULT_FILE%
	echo 																														>> %RESULT_FILE% 
	echo [66-END]                                                                              									>> %RESULT_FILE%
	echo [W-66]Result : GOOD 																									>> %RESULT_FILE%
) else ( 
	echo 원격 시스템에서 시스템종료를 Administrators 이외의 권한에서 가능함으로 취약함          								>> %RESULT_FILE% 
	echo. 																														>> %RESULT_FILE% 
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "SeRemoteShutdownPrivilege"                         								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE% 
	echo [66-END]                                                                              									>> %RESULT_FILE%
	echo [W-66]Result : VULNERABLE                                                         										>> %RESULT_FILE%
)
del tmp_66_1.txt
del tmp_66_2.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.              																												>> %RESULT_FILE%
echo -------------알려진 로컬ID 리스트  ---------    																			>> %RESULT_FILE%
echo Administrators의 디폴트 ID값  = *S-1-5-32-544                                 												>> %RESULT_FILE% 
echo IUSR_[ComputerName]           = *S-1-5-17                                            										>> %RESULT_FILE%
echo Users 						   = *S-1-5-32-545                                                    							>> %RESULT_FILE%
echo Guests						   = *S-1-5-32-546												 								>> %RESULT_FILE%
echo Power Users                   = *S-1-5-32-547 											 									>> %RESULT_FILE%
echo Backup Operators              = *S-1-5-32-551                                           									>> %RESULT_FILE%
echo Remote Desktop Users          = *S-1-5-32-555																				>> %RESULT_FILE%
echo ----------------------------------------------                   															>> %RESULT_FILE%
echo.                                                                                       									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-66 END


rem W-67 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-67] 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료  	 	 	  														>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [67-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | Find /I "CrashOnAuditFail" | Find "4,0" >NUL
IF NOT ERRORLEVEL 1 (
	echo 보안 감사를 로그할 수 없어도 시스템이 즉시종료되지 않으므로 양호함                  									>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "CrashOnAuditFail"                                  								>> %RESULT_FILE%
	echo [67-END]                                                                           									>> %RESULT_FILE%
	echo [W-67]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 보안 감사를 로그할수 없으면 시스템이 즉시 종료됨으로 취약함             												>> %RESULT_FILE%
	echo.																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | Find /I "CrashOnAuditFail"                                  								>> %RESULT_FILE%
	echo [67-END]                                                                           									>> %RESULT_FILE%
	echo [W-67]Result : VULNERABLE 																								>> %RESULT_FILE%
)
echo. 																															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료                                                                        	>> %RESULT_FILE%
echo CrashOnAuditFail = 4,0 (보안 감사를 로그할수 없을때 즉시종료 안함)                                                  		>> %RESULT_FILE%
echo CrashOnAuditFail = 4,1 (보안 감사를 로그할수 없을때 즉시종료됨)                           									>> %RESULT_FILE%
echo 0이면 양호 1이면 취약함                                                                   									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-67 END

rem W-68 Start 
echo ############################################################ >> %RESULT_FILE%
echo [W-68] SAM 계정과 공유의 익명 열거 허용 안 함 >> %RESULT_FILE%
echo ############################################################ >> %RESULT_FILE%
echo [68-START] >> %RESULT_FILE%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /I "restrictanonymoussam" | find "1" 
set SAM_RESULT=%ERRORLEVEL%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /I "restrictanonymous" | find "1" | find /v "sam"
set ANONYMOUS_RESULT=%ERRORLEVEL%

IF NOT %SAM_RESULT% EQU 0 (
    goto VULNERABLE_SECTION
)

IF NOT %ANONYMOUS_RESULT% EQU 0 (
    goto VULNERABLE_SECTION
)

echo SAM 계정과 공유의 익명 열거 허용 안함 기능을 각각 활성화 되어있어 양호함 >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo [현황] >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /I "restrictanonymoussam" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /I "restrictanonymous" | find /v "sam" >> %RESULT_FILE%
echo [68-END] >> %RESULT_FILE%
echo [W-68]Result : GOOD >> %RESULT_FILE%
goto END_SECTION

:VULNERABLE_SECTION
echo SAM 계정과 공유의 익명 열거 허용 안함 기능을 각각 설정하지 않으므로 취약함 >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo [현황] >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /I "restrictanonymoussam" >> %RESULT_FILE%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /I "restrictanonymous" | find /v "sam" >> %RESULT_FILE%
echo [68-END] >> %RESULT_FILE%
echo [W-68]Result : VULNERABLE >> %RESULT_FILE%

:END_SECTION
echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo ---------- [참고] --------------------------- >> %RESULT_FILE%
echo SAM 계정과 공유의 익명 열거 허용 안 함 >> %RESULT_FILE%
echo restrictanonymoussam = SAM 계정의 익명 열거 허용 안함 사용 >> %RESULT_FILE%
echo restrictanonymous = SAM 계정과 공유의 익명 열거 허용 안함 >> %RESULT_FILE%
echo 두 값이 모두 1(사용)이면양호     0(미사용)이면 취약 >> %RESULT_FILE%
echo ---------------------------------------------- >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%
rem W-68 END


rem W-69 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-69] AutoLogon 기능 제어 	  	 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [69-START] 																												>> %RESULT_FILE%
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /s  > tmp_69_1.txt
type tmp_69_1.txt | find /i "AutoAdminLogon" | find "1"  
IF NOT ERRORLEVEL 1 (
	echo AutoLogon 기능을 사용하고 있으므로 취약함              																>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_69_1.txt | find /i "AutoAdminLogon"   																				>> %RESULT_FILE%
	type tmp_69_1.txt | find /i "DefaultUserName"   																			>> %RESULT_FILE%
	type tmp_69_1.txt | find /i "DefaultPassword"   																			>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [69-END]                                                                               								>> %RESULT_FILE%
	echo [W-69]Result : VULNERABLE                                                                              				>> %RESULT_FILE%
) else (
	echo AutoLogon 기능을 사용하지 않으므로 양호함           																	>> %RESULT_FILE%	
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_69_1.txt | find /i "AutoAdminLogon"   																				>> %RESULT_FILE%
	type tmp_69_1.txt | find /i "DefaultUserName"   																			>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [69-END]                                                                               								>> %RESULT_FILE%
	echo [W-69]Result : GOOD                                                                              						>> %RESULT_FILE%
)                                                
del tmp_69_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo AutoLogon 기능 제어                                                                        								>> %RESULT_FILE%
echo AutoAdminLogon   =  자동로그인기능                                                      									>> %RESULT_FILE%
echo DefaultUserName  =  자동로그인을 사용할 디폴트 계정                                      									>> %RESULT_FILE%
echo DefaultPassword  =  자동로그인할 계정의 패스워드                                         									>> %RESULT_FILE%
echo AutoAdminLogon이 1이면 취약  DefaultPassword값 있으면 취약                              									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-69 END


rem W-70 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-70] 이동식 미디어 포맷 및 꺼내기 허용 	  	 	 	  																	>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [70-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | Find /I "AllocateDASD"  
IF ERRORLEVEL 1 (
	echo 이동식 미디어 포맷 및 꺼내기 허용 보안옵션이 정의되지 않았으므로 양호함                  								>> %RESULT_FILE%
	echo [70-END]                                                                              									>> %RESULT_FILE%
	echo [W-70]Result : GOOD                                                                             					>> %RESULT_FILE% 
) else (
	type Local_Security_Policy.txt | Find /I "AllocateDASD"                                      > tmp_70_1.txt
	For /F "tokens=2 delims=," %%j IN (tmp_70_1.txt) DO @echo %%j | find "0" > NUL
	IF NOT ERRORLEVEL 1 (
		echo 이동식 미디어 포맷 및 꺼내기를 Administrators 그룹만 가능함으로 양호함          									>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type Local_Security_Policy.txt | Find /I "AllocateDASD"                                      							>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [70-END]                                                                              								>> %RESULT_FILE%
		echo [W-70]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo 이동식 미디어 포맷 및 꺼내기를 Administrators 이외의 그룹이 포함되어 취약함       									>> %RESULT_FILE%                                                        >> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type Local_Security_Policy.txt | Find /I "AllocateDASD"                                      							>> %RESULT_FILE%
		echo.	 																												>> %RESULT_FILE%
		echo [70-END]                                                                              								>> %RESULT_FILE%
		echo [W-70]Result : VULNERABLE                                                             								>> %RESULT_FILE%
	)
)
del tmp_70_1.txt
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 이동식 미디어 포맷 및 꺼내기 허용                                               											>> %RESULT_FILE%
echo AllocateDASD  = 1,0 (Administrators 그룹허용)                 																>> %RESULT_FILE%
echo AllocateDASD  = 1,1 (Administrators 및 Power Users)           																>> %RESULT_FILE%
echo AllocateDASD  = 1,2 (Administrators 및 Interactive Users)                            										>> %RESULT_FILE%
echo 1,0 이면 양호 그외 취약                                                                    								>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-70 END


rem W-71 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-71] 디스크볼륨 암호화 설정 	  	 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [71-START] 																												>> %RESULT_FILE%
echo  WIN 2008, 7, 2012 해당사항 없음 																							>> %RESULT_FILE%
echo [71-END] 																													>> %RESULT_FILE%
echo [W-71]Result : N/A 																										>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                         	 									>> %RESULT_FILE%
echo 디스크볼륨 암호화 설정                                               														>> %RESULT_FILE%
echo 디스크볼륨 암호화는 폴더마다 중요한 데이터를 암호화 시키는 항목                 											>> %RESULT_FILE%
echo 양이 너무 방대하여 진단 불가                                            													>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-71 END


rem W-72 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-72] Dos공격 방어 레지스트리 설정 	  	 	 	  																		>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [72-START] 																												>> %RESULT_FILE%
REM echo  WIN 2008, 7, 2012 해당사항 없음 																							>> %RESULT_FILE%
echo DoS 공격 방어 레지스트리가 설정되어 있지 않습니다. >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo #reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v SynAttackProtect >> %RESULT_FILE%
reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v SynAttackProtect >> %RESULT_FILE%
echo #reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v EnableDeadGWDetect >> %RESULT_FILE%
reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v EnableDeadGWDetect >> %RESULT_FILE%
echo #reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v KeepAliveTime >> %RESULT_FILE%
reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v KeepAliveTime >> %RESULT_FILE%
echo #reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v NoNameReleaseOnDemand >> %RESULT_FILE%
reg query HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v NoNameReleaseOnDemand >> %RESULT_FILE%

echo [72-END] 																													>> %RESULT_FILE%
echo [W-72]Result : N/A 																										>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                         	 									>> %RESULT_FILE%
echo 디스크볼륨 암호화 설정                                               														>> %RESULT_FILE%
echo 디스크볼륨 암호화는 폴더마다 중요한 데이터를 암호화 시키는 항목                 											>> %RESULT_FILE%
echo 양이 너무 방대하여 진단 불가                                            													>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-72 END


rem W-73 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-73] 사용자가 프린터 드라이버를 설치할 수 없게 함   	  	 	 	  														>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [73-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | find /i "AddPrinterDrivers" | Find "4,0"
IF ERRORLEVEL 1 (
	ECHO "사용자가 프린터 드라이버를 설치할 수 없게 함" 정책을 사용하고 있어 양호함                                             >> %RESULT_FILE%
	echo.  																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%	
	type Local_Security_Policy.txt | find /i "AddPrinterDrivers"   																>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%	
	echo [73-END]    																											>> %RESULT_FILE%
	echo [W-73]Result : GOOD 																									>> %RESULT_FILE%
) else (
	ECHO "사용자가 프린터 드라이버를 설치할 수 없게 함" 정책을 사용하지 않으므로 취약함                                         >> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /i "AddPrinterDrivers"   																>> %RESULT_FILE% 
	echo.  																														>> %RESULT_FILE%
	echo [73-END]    																											>> %RESULT_FILE%
	echo [W-73]Result : VULNERABLE 																								>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                             >> %RESULT_FILE%
echo                          >> %RESULT_FILE%
echo                                >> %RESULT_FILE%
echo                              >> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-73 END


rem W-74 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-74] 세션 연결을 중단하기 전에 필요한 유휴 시간 	  	 	 	  															>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [74-START] 																												>> %RESULT_FILE%
%script%\reg.exe query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\EnableForcedLogOff" > tmp_74_1.txt
%script%\reg.exe query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect" > tmp_74_2.txt
type tmp_74_1.txt | find "0" 
if not errorlevel 1 goto CHECKVAR
for /f "tokens=3" %%a in (tmp_74_2.txt) do set var=%%a
if %var% LSS 16 (
	goto GOOD
) else (
	goto VULNERABLE
)

:CHECKVAR
echo 세션 연결을 중단하기 전에 필요한 유휴시간 설정이 정책에 맞게 설정되지 않으므로 취약함 									>> %RESULT_FILE%
echo. 																														>> %RESULT_FILE%
echo [현황] 																												>> %RESULT_FILE%
type tmp_74_1.txt 																											>> %RESULT_FILE%
type tmp_74_2.txt 																											>> %RESULT_FILE%
echo [74-END] 																												>> %RESULT_FILE%
echo. 																														>> %RESULT_FILE%
echo [W-74]Result : VULNERABLE																								>> %RESULT_FILE%
goto END

:GOOD
echo 세션 연결을 중단하기 전에 필요한 유휴시간 설정이 정책에 맞게 설정되어 있으므로 양호함 								>> %RESULT_FILE%
echo. 																													>> %RESULT_FILE%
echo [현황] 																											>> %RESULT_FILE%
type tmp_74_1.txt 																										>> %RESULT_FILE%
type tmp_74_2.txt 																										>> %RESULT_FILE%
echo. 																													>> %RESULT_FILE%
echo [74-END] 																											>> %RESULT_FILE%
echo [W-74]Result : GOOD 																								>> %RESULT_FILE%
goto END

:VULNERABLE
echo 세션 연결을 중단하기 전에 필요한 유휴시간 설정이 정책에 맞게 설정되지 않으므로 취약함 									>> %RESULT_FILE%
echo. 																														>> %RESULT_FILE%
echo [현황] 																												>> %RESULT_FILE%
type tmp_74_1.txt 																											>> %RESULT_FILE%
type tmp_74_2.txt 																											>> %RESULT_FILE%
echo [74-END] 																												>> %RESULT_FILE%
echo. 																														>> %RESULT_FILE%
echo [W-74]Result : VULNERABLE																								>> %RESULT_FILE%
goto END

:END
echo.
echo [참고]
reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters"
del tmp_74_1.txt
del tmp_74_2.txt                                                                                    
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 세션 연결을 중단하기 전에 필요한 유휴 시간                                            										>> %RESULT_FILE%
echo EnableForcedLogOff - 로그온 시간이 만료되면 클라이언트 연결 끊기                         									>> %RESULT_FILE%
echo AutoDisconnect - 세션 연결을 중단하기 전에 필요한 유휴 시간                                								>> %RESULT_FILE%
echo EnableforcedLogoff값 1이고 AutoDisconnect값 15 이하이면 양호                             									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-74 END

rem W-75 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-75] 경고 메시지 설정 	  	 	 	  																					>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [75-START] 																												>> %RESULT_FILE%
%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption" | %script%\gawk.exe "{print $3}" | %script%\wc.exe -w | find "0"
if errorlevel 1 (
	%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext" | %script%\gawk.exe "{print $3}" | %script%\wc.exe -w | find "0"
	if errorlevel 1 (
		echo 로그온 경고 메시지가 설정됨 																						>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		echo HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption 									>> %RESULT_FILE%
		%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption" 				>> %RESULT_FILE%
		echo HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext 									>> %RESULT_FILE%
		%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext" 				>> %RESULT_FILE%
		echo [75-END] 																											>> %RESULT_FILE%
		echo [W-75]Result : GOOD 																								>> %RESULT_FILE%
	)
) else (
	echo 로그온 경고 메시지가 설정되지 않으므로 취약함 																			>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	echo HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption 										>> %RESULT_FILE%
	%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption" 					>> %RESULT_FILE%
	echo HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext 										>> %RESULT_FILE%
	%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext" 					>> %RESULT_FILE%
	echo [75-END] 																												>> %RESULT_FILE%
	echo [W-75]Result : VULNERABLE 																								>> %RESULT_FILE%
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                             >> %RESULT_FILE%
echo                          >> %RESULT_FILE%
echo                                >> %RESULT_FILE%
echo                              >> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-75 END


rem W-76 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-76] 사용자별 홈 디렉터리 권한 설정 	  	 	 	  																		>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [76-START] 																												>> %RESULT_FILE%
dir "C:\Users\*" | find "<DIR>"  | findstr /V "Public All Default ." > tmp_76_1.txt
for /f "tokens=5" %%a in (tmp_54_1.txt) do Icacls "C:\Documents and Settings\%%a" >> tmp_76_2.txt
type tmp_76_2.txt | find /i "everyone"
if errorlevel 1 (
	echo 사용자별 홈 디렉터리의 권한에 Everyone 계정이 존재하지 않으므로 양호함 												>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_76_2.txt 																											>> %RESULT_FILE%
	echo [76-END] 																												>> %RESULT_FILE%
	echo [W-76]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 사용자별 홈 디렉터리의 권한에 Everyone 계정이 존재하므로 취약함 														>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type tmp_76_2.txt 																											>> %RESULT_FILE%
	echo [76-END] 																												>> %RESULT_FILE%
	echo [W-76]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
del tmp_76_1.txt
del tmp_76_2.txt
echo. 																															>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 사용자별 홈 디렉터리 권한 설정                                                                         					>> %RESULT_FILE%
echo 각 계정들의 홈디렉터리에 everyone 계정이 존재하면 취약                                										>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-76 END


rem W-77 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-77] LAN Manager 인증 수준	  	 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [77-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | find /i "LmCompatibilityLevel"
if errorlevel 1 (
	echo LAN Manager 인증 수준 보안옵션이 정의되지 않았으므로 양호함 															>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /i "LmCompatibilityLevel" 															>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [77-END] 																												>> %RESULT_FILE%
	echo [W-77]Result : VULNERABLE 																								>> %RESULT_FILE% 
) else (
	type Local_Security_Policy.txt | find /i "LmCompatibilityLevel" | find "4,3"
	if not errorlevel 1 (
		echo LAN Manager 인증 수준 보안옵션이 'NTLMv2 응답만 보냄'으로 설정되어 있으므로 양호함 								>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type Local_Security_Policy.txt | find /i "LmCompatibilityLevel" 														>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [77-END] 																											>> %RESULT_FILE%
		echo [W-77]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo LAN Manager 인증 수준 보안옵션이 'NTLMv2 응답만 보냄'으로 설정되지 않았으므로 취약함 								>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type Local_Security_Policy.txt | find /i "LmCompatibilityLevel" 														>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [77-END] 																											>> %RESULT_FILE%
		echo [W-77]Result : VULNERABLE 																							>> %RESULT_FILE%
	)
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo LAN Manager 인증 수준                                                                   									>> %RESULT_FILE%
echo lmcompatibilitylevel  =  0 (LM and NTLM 응답 보냄)                                   										>> %RESULT_FILE%
echo lmcompatibilitylevel  =  1 (LM and NTLM - NTLMv2 세션 보안 사용(협상된 경우))         										>> %RESULT_FILE%
echo lmcompatibilitylevel  =  2 (NTLM 응답 보냄)                                          										>> %RESULT_FILE%
echo lmcompatibilitylevel  =  3 (NTLMv2 응답만 보냄)                              												>> %RESULT_FILE%
echo lmcompatibilitylevel  =  4 (NTLMv2 응답만 보냄\LM 거부)                               										>> %RESULT_FILE%
echo lmcompatibilitylevel  =  5 (NTLMv2 응답만 보냄\LM and NTLM 거부)                           								>> %RESULT_FILE%
echo 3이상 양호 미만은 취약                                                                    									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-77 END


rem W-78 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-78] 보안 채널 데이터 디지털 암호화 또는 서명 	  	 	 	  															>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [78-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | findstr /i "RequireSignOrSeal SealSecureChannel SignSecureChannel" | Find "4,0"
if errorlevel 1 (
	echo 보안 채널 데이터 디지털 암호화 또는 서명 보안옵션이 '사용'으로 설정되어 있으므로 양호함  								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | findstr /i "RequireSignOrSeal SealSecureChannel SignSecureChannel" 						>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [78-END] 																												>> %RESULT_FILE%
	echo [W-78]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo 보안 채널 데이터 디지털 암호화 또는 서명 보안옵션이 '사용안함'으로 설정되어 있으므로 취약함  							>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | findstr /i "RequireSignOrSeal SealSecureChannel SignSecureChannel" 						>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [78-END] 																												>> %RESULT_FILE%
	echo [W-78]Result : VULNERABLE 																								>> %RESULT_FILE% 
)

echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 보안 채널 데이터 디지털 암호화 또는 서명                                               									>> %RESULT_FILE%
echo requiresignorseal  =  보안 채널 데이터를 디지털 암호화 또는 서명                 											>> %RESULT_FILE%
echo sealsecurechannel  =  보안 채널 데이터를 디지털 암호화               														>> %RESULT_FILE%
echo signsecurechannel  =  보안 채널 데이터를 디지털 서명                            											>> %RESULT_FILE%
echo 전부 1(사용함)이면 양호 그외 취약                                                                    						>> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-78 END


rem W-79 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-79] 파일 및 디렉토리 보호	  	 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [79-START] 																												>> %RESULT_FILE%
fsutil fsinfo volumeinfo c:\ | find /i "File System Name" | find /i "NTFS"
if not errorlevel 1 (
	echo NTFS 파일시스템을 사용함 																								>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	fsutil fsinfo volumeinfo c:\ | find /i "File System Name" 																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [79-END] 																												>> %RESULT_FILE%
	echo [W-79]Result : GOOD 																									>> %RESULT_FILE%
) else (
	echo NTFS 파일시스템을 사용하지 않음 																						>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	fsutil fsinfo volumeinfo c:\ | find /i "File System Name" 																	>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [79-END] 																												>> %RESULT_FILE%
	echo [W-79]Result : VULNERABLE 																								>> %RESULT_FILE% 
)
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo                                                									>> %RESULT_FILE%
echo                  											>> %RESULT_FILE%
echo                														>> %RESULT_FILE%
echo                             											>> %RESULT_FILE%
echo                                                                     						>> %RESULT_FILE%
echo ----------------------------------------------                                         									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
rem W-79 END


rem W-80 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-80] 컴퓨터 계정 암호 최대 사용 기간	  	 	 	  																		>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [80-START] 																												>> %RESULT_FILE%
type Local_Security_Policy.txt | find /i "DisablePasswordChange" | find "4,0"
if not errorlevel 1 (
	@REM type Local_Security_Policy.txt | find /i "\MaximumPasswordAge" | %script%\gawk.exe -F, "{print$2}" > tmp_80_1.txt
	type Local_Security_Policy.txt | find /i "\MaximumPasswordAge" > tmp_80_1.txt
	for /f "tokens=2 delims=," %%a in (tmp_80_1.txt) do set var=%%a
	@REM if %var% LSS 91 (
	if !var! LSS 91 (
		echo 컴퓨터 계정 암호 최대 사용 보안옵션이 정책에 맞게 설정되어 있으므로 양호함 										>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [현황] 																											>> %RESULT_FILE%
		type Local_Security_Policy.txt | find /i "DisablePasswordChange" 														>> %RESULT_FILE%
		type Local_Security_Policy.txt | find /i "\MaximumPasswordAge" 															>> %RESULT_FILE%
		echo. 																													>> %RESULT_FILE%
		echo [80-END] 																											>> %RESULT_FILE%
		echo [W-80]Result : GOOD 																								>> %RESULT_FILE%
	) else (
		echo 컴퓨터 계정 암호 최대 사용 보안옵션이 정책에 맞게 설정되어 있지 않으므로 취약함 										>> %RESULT_FILE%
		echo. 																														>> %RESULT_FILE%
		echo [현황] 																												>> %RESULT_FILE%
		type Local_Security_Policy.txt | find /i "DisablePasswordChange" 															>> %RESULT_FILE%
		type Local_Security_Policy.txt | find /i "\MaximumPasswordAge" 																>> %RESULT_FILE%
		echo. 																														>> %RESULT_FILE%
		echo [80-END]																												>> %RESULT_FILE%
		echo [W-80]Result : VULNERABLE 																								>> %RESULT_FILE%
	)
) else (
	echo 컴퓨터 계정 암호 최대 사용 보안옵션이 정책에 맞게 설정되어 있지 않으므로 취약함 										>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [현황] 																												>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /i "DisablePasswordChange" 															>> %RESULT_FILE%
	type Local_Security_Policy.txt | find /i "\MaximumPasswordAge" 																>> %RESULT_FILE%
	echo. 																														>> %RESULT_FILE%
	echo [80-END]																												>> %RESULT_FILE%
	echo [W-80]Result : VULNERABLE 																								>> %RESULT_FILE%
)
del tmp_80_1.txt
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 컴퓨터 계정 암호 최대 사용 기간                                               												>> %RESULT_FILE%
echo DisablePasswordChange =  컴퓨터 계정 암호 변경 사용 안 함               													>> %RESULT_FILE%
echo OMaximumPasswordAge   =  컴퓨터 계정 암호 최대 사용 기간                                       							>> %RESULT_FILE%
echo DisablePasswordChange 0이면 양호 OMaximumpassrordage 90일 이하이면 양호                   									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
rem W-80 END


rem W-81 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-81] 시작프로그램 목록 분석	  	 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [81-START] 																												>> %RESULT_FILE%
echo 인터뷰를 통해 불필요한 시작프로그램 검토 																					>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo [현황] 																													>> %RESULT_FILE%
echo HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run 																		>> %RESULT_FILE%
%script%\reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | find "REG_SZ" 									>> %RESULT_FILE%
echo HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run 																		>> %RESULT_FILE%
%script%\reg.exe query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | find "REG_SZ" 									>> %RESULT_FILE%
echo.  																															>> %RESULT_FILE%
echo [81-END]																													>> %RESULT_FILE%
echo [W-81]Result : MANUAL 																										>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo ---------- [참고] ---------------------------                                          									>> %RESULT_FILE%
echo 컴퓨터 계정 암호 최대 사용 기간                                               												>> %RESULT_FILE%
echo DisablePasswordChange =  컴퓨터 계정 암호 변경 사용 안 함               													>> %RESULT_FILE%
echo OMaximumPasswordAge   =  컴퓨터 계정 암호 최대 사용 기간                                       							>> %RESULT_FILE%
echo DisablePasswordChange 0이면 양호 OMaximumpassrordage 90일 이하이면 양호                   									>> %RESULT_FILE%
echo ----------------------------------------------                                          									>> %RESULT_FILE%
echo. 																															>> %RESULT_FILE%
echo.																															>> %RESULT_FILE%
rem W-81 END


rem W-82 Start 
echo ############################################################ 																>> %RESULT_FILE%
echo [W-82] Windows 인증 모드 사용	  	 	 	  																				>> %RESULT_FILE%
echo ############################################################ 																>> %RESULT_FILE%
echo [82-START] 																												>> %RESULT_FILE%
echo 해당 항목은 DB점검과 중복 됨																											>> %RESULT_FILE%
echo [82-END] 																													>> %RESULT_FILE%
echo [W-82]Result : MANUAL 																										>> %RESULT_FILE%
echo.                                                                            												>> %RESULT_FILE%

goto Total_epilogue


:Total_epilogue
del iis-check.txt
del servicePack.txt



::echo ------------------------------ 별 첨 ------------------------------ >> %RESULT_FILE%
::echo [W-55] 최신 HOT FIX 적용 >> %RESULT_FILE%
::wmic QFE Get HotFixID,InstalledOn >> %RESULT_FILE%
::echo ------------------------------ E N D ---------------------------- >> %RESULT_FILE%


echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%
echo ###############################    network information    ############################# >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%
ipconfig /all                                                                                >> %RESULT_FILE%
echo.                                                                                        >> %RESULT_FILE%
echo.                                                                                        >> %RESULT_FILE%

echo ####################################################################################### >> %RESULT_FILE%
echo #################################  Port Information  ################################## >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%
netstat -an | find /v "TIME_WAIT"                                                            >> %RESULT_FILE%
echo.                                                                                        >> %RESULT_FILE%
echo.         

echo ####################################################################################### >> %RESULT_FILE%
echo ##########################  Environment Variable Information  ######################### >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%
echo.                                                                                        >> %RESULT_FILE%
set											   										         >> %RESULT_FILE%
echo. 																						 >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%
echo ##################################  systeminfo  ####################################### >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%
systeminfo                                                                                   >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%

echo ####################################################################################### >> %RESULT_FILE%
echo ###############################  Security Policy  ##################################### >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%

type Local_Security_Policy.txt >> %RESULT_FILE%

del Local_Security_Policy.txt

echo ####################################################################################### >> %RESULT_FILE%
echo ###################################  Service  ######################################### >> %RESULT_FILE%
echo ####################################################################################### >> %RESULT_FILE%

net start                                                                                    >> %RESULT_FILE%
echo. >> %RESULT_FILE%
echo. >> %RESULT_FILE%

echo ####################################################################################### 									>> %RESULT_FILE%
echo #############################  Tomcat-users Information  ############################## 									>> %RESULT_FILE%
echo #######################################################################################								    >> %RESULT_FILE%
set info = dir /S /B c:\ | findstr -s -i tomcat-users
type "%info%"                                                      									                            >> %RESULT_FILE%
echo.                                                                                        									>> %RESULT_FILE%
echo.																															>> %RESULT_FILE%

echo ##########################   END  ########################## >> %RESULT_FILE%


:END

EXIT
