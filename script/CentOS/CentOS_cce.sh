#!/bin/bash

LANG=C
export LANG

TARGETIP=$(ip addr show | grep "inet " | grep -v "127.0.0.1" | head -n 1 | awk '{print $2}' | cut -d '/' -f 1)
TESTEDTIME=$(date '+%Y-%m-%d %H:%M:%S')
OSINFO=$(grep "^PRETTY_NAME=" /etc/os-release | awk -F'=' '{print $2}' | tr -d '"' || (grep "^NAME=" /etc/os-release | awk -F'=' '{print $2}' | tr -d '"'; echo -n " "; grep "^VERSION=" /etc/os-release | awk -F'=' '{print $2}' | tr -d '"') | tr '\n' ' ' | sed 's/ $//')

#RESULT_FILE=./Ubuntu'_'$TARGETIP'_'$(date '+%Y%m%d%H%M%S').json
RESULT_FILE=./CentOS'_'$TARGETIP.json

echo \{ >> $RESULT_FILE 2>&1
echo \"targetip\"\: \"$TARGETIP\", >> $RESULT_FILE 2>&1
echo \"testedtime\"\: \"$TESTEDTIME\", >> $RESULT_FILE 2>&1
echo \"osinfo\"\: \"$OSINFO\", >> $RESULT_FILE 2>&1
echo \"result\"\: \[ >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-1]root 계정 원격 접속 제한
echo \"itemcode\"\: \"'U-01'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'root 계정 원격 접속 제한'\", >> $RESULT_FILE 2>&1
echo [1-START]
if [ `find /etc -type f -name "sshd_config" | wc -l` -eq 0 ]
then
    echo \"result\"\: 2, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'sshd_config 파일을 찾을 수 없음'\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'sshd_config 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
    echo [1-END]
    echo [U-1]Result : MANUAL
else
    SSHCONFIG=`find /etc -type f -name "sshd_config"`
    if [ `grep -i "permitrootlogin" $SSHCONFIG | grep -v "setting" | grep -v "#" | grep -i "no" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'grep -i \"permitrootlogin\" $SSHCONFIG | grep -v \"setting\" | grep -v \"without\" 의 결과: 0'\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'root 계정 원격 접속이 제한되지 않으므로 취약함'\" >> $RESULT_FILE 2>&1
	grep -i "permitrootlogin" $SSHCONFIG | grep -v "setting" | grep -v "without"
	echo [1-END]
	echo [U-1]Result : VULNERABLE
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'grep -i \"permitrootlogin\" $SSHCONFIG | grep -v \"setting\" | grep -v \"without\" 의 결과: 1'\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'root 계정 원격 접속이 제한되므로 양호함'\" >> $RESULT_FILE 2>&1
	grep -i "permitrootlogin" $SSHCONFIG | grep -v "setting" | grep -v "without"
	echo [1-END]
	echo [U-1]Result : GOOD
    fi
    
fi 
echo "[참고]"
echo "PermitRootLogin prohibit-password = 비밀번호 인증만 제한(인증키 로그인은 제한하지 않음)"
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-2]패스워드 복잡성 설정
echo \"itemcode\"\: \"'U-02'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'패스워드 복잡성 설정'\", >> $RESULT_FILE 2>&1
echo [2-START]
if [ `find /etc -name "system-auth" | wc -l` -eq 0 ]
then
    echo \"result\"\: 2, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'find /etc -name \"system-auth\" 의 결과: null'\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'system-auth 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
    echo [2-END]
    echo [U-2]Result : MANUAL
else
    SYSAUTH=`find /etc -name "system-auth"`
    if [ `grep -i "password" $SYSAUTH | grep -v "#" | grep "requisite" | grep "lcredit" | grep "dcredit" | grep "ocredit" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'grep -i \"password\" $SYSAUTH | grep -v \"#\" 의 결과: '$(grep -i "password" $SYSAUTH | grep -v "#")\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'패스워드 복잡성 설정이 적용되어 있지 않으므로 취약함'\" >> $RESULT_FILE 2>&1
	grep -i "password" $SYSAUTH | grep -v "#"
	echo [2-END]
	echo [U-2]Result : VULNERABLE
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'grep -i \"password\" $SYSAUTH | grep -v \"#\" 의 결과: '$(grep -i "password" $SYSAUTH | grep -v "#")\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'패스워드 복잡성 설정이 적용되어 있으므로 양호함'\" >> $RESULT_FILE 2>&1
	grep -i "password" $SYSAUTH | grep -v "#"                                                                                       	>> $RESULT_FILE 2>&1
	echo [2-END]
	echo [U-2]Result : GOOD
    fi
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-3]계정 잠금 임계값 설정
echo \"itemcode\"\: \"'U-03'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'계정 잠금 임계값 설정'\", >> $RESULT_FILE 2>&1
echo [3-START]
if [ `find /etc -name "system-auth" | wc -l` -eq 0 ]
then
    echo \"result\"\: 2, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'find /etc -name \"system-auth\" 의 결과: '$(find /etc -name "system-auth")\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'common-password 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
    echo [3-END]
    echo [U-3]Result : MANUAL
else
    SYSAUTH=`find /etc -name "system-auth"`
    if [ `grep -i "password" $SYSAUTH | grep "requisite" | grep -v "#" | grep "retry" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'grep -i \"password\" $SYSAUTH | grep \"requisite\" | grep -v \"#\" | grep \"retry\" | wc -l 의 결과: '$(grep -i "password" $SYSAUTH | grep "requisite" | grep -v "#" | grep "retry" | wc -l)\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'계정 잠금 임계값이 적용되어 있지 않으므로 취약함'\" >> $RESULT_FILE 2>&1
	grep -i "password" $SYSAUTH | grep -v "#"
	echo [3-END]
	echo [U-3]Result : VULNERABLE
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'grep -i \"password\" $SYSAUTH | grep \"requisite\" | grep -v \"#\" | grep \"retry\" | wc -l 의 결과: '$(grep -i "password" $SYSAUTH | grep "requisite" | grep -v "#" | grep "retry" | wc -l)\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'계정 잠금 임계값이 적용되어 있으므로 양호함'\" >> $RESULT_FILE 2>&1
	grep -i "password" $SYSAUTH | grep -v "#"
	echo [3-END]
	echo [U-3]Result : GOOD
    fi
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-04]패스워드 최대 사용 기간 설정
echo \"itemcode\"\: \"'U-04'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'패스워드 최대 사용 기간 설정'\", >> $RESULT_FILE 2>&1
echo [04-START]
RE_47_1=1
RE_47_2=1
if [ `grep "PASS_MAX_DAYS" /etc/login.defs | grep -v "#" | wc -l` -eq 0 ]
then
    RE_47_1=0
else
    if [ `grep "PASS_MAX_DAYS" /etc/login.defs | grep -v "#" | awk '{print $2}'` -gt 90 ]
    then
	RE_47_1=0
    fi
fi
cat /etc/shadow | awk -F: '$2!="*" {print $0}' | awk -F: '$2!="!!" {print $1,":",$5}' > tmp_47_1.txt
for var in `cat tmp_47_1.txt | awk '{print $NF}'`
do
    if [ $var == ":" ]
    then
	RE_47_2=0
    elif [ $var -gt 90 ]
    then
	RE_47_2=0
    else
	true
    fi
done
if [ $RE_47_1 -eq 1 ]
then
    if [ $RE_47_2 -eq 1 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'1) PASS_MAX_DAYS 설정의 결과: '$(grep "PASS_MAX_DAYS :" /etc/login.defs | grep -v "#" | tr '\n' ' ')', 2) 각 계정별 패스워드 최대 사용기간 설정: '$(cat tmp_47_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'PASS_MAX_DAYS 값 및 각 계정에 적용된 패스워드 최대 사용기간이 정책에 맞게 적용되어 있으므로 양호함'\" >> $RESULT_FILE 2>&1
	grep "PASS_MAX_DAYS :" /etc/login.defs | grep -v "#"
	cat tmp_47_1.txt
	echo [47-END]
	echo [U-47]Result : GOOD
    else
	echo \"result\"\: 2, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'1) PASS_MAX_DAYS 설정의 결과: '$(grep "PASS_MAX_DAYS :" /etc/login.defs | grep -v "#" | tr '\n' ' ')', 2) 각 계정별 패스워드 최대 사용기간 설정: '$(cat tmp_47_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'PASS_MAX_DAYS 값은 기준에 맞게 설정되어 있으나, 각 계정에 적용된 패스워드 최대 사용기간이 정책에 맞지 않는 계정이 존재함'\" >> $RESULT_FILE 2>&1
	grep "PASS_MAX_DAYS :" /etc/login.defs | grep -v "#"
	cat tmp_47_1.txt
	echo [47-END]
	echo [U-47]Result : MANUAL
    fi
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'1) PASS_MAX_DAYS 설정의 결과: '$(grep "PASS_MAX_DAYS :" /etc/login.defs | grep -v "#" | tr '\n' ' ')', 2) 각 계정별 패스워드 최대 사용기간 설정: '$(cat tmp_47_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'PASS_MAX_DAYS 값 및 각 계정에 적용된 패스워드 최대 사용기간이 정책에 맞지 않으므로 취약함'\" >> $RESULT_FILE 2>&1
    grep "PASS_MAX_DAYS :" /etc/login.defs | grep -v "#"
    cat tmp_47_1.txt
    echo [47-END]
    echo [U-47]Result : VULNERABLE
fi
rm -rf tmp_47_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-5]패스워드 파일 보호
echo \"itemcode\"\: \"'U-05'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'패스워드 파일 보호'\", >> $RESULT_FILE 2>&1
echo [5-START]
if [ `head -1 /etc/passwd | awk -F: '{print $2}' | egrep "^x" | wc -c` -eq 2 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'head -1 /etc/passwd 의 결과: '$(head -1 /etc/passwd | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'패스워드를 /etc/passwd 파일에 저장하지 않고 별도의 파일에 저장하므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [4-END]
    echo [U-4]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'head -1 /etc/passwd 의 결과: '$(head -1 /etc/passwd | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'패스워드를 /etc/passwd 파일에 저장하므로 취약함'\" >> $RESULT_FILE 2>&1
    head -1 /etc/passwd
    echo [4-END]
    echo [U-4]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-6]root 홈, 패스 디렉터리 권한 및 패스 설정
echo \"itemcode\"\: \"'U-06'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'root 홈, 패스 디렉터리 권한 및 패스 설정'\", >> $RESULT_FILE 2>&1
echo [6-START]
if [ `echo $PATH | grep "\.:" | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'echo $PATH 의 결과: '$(echo $PATH | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'PATH 환경변수에 '.'이 맨 앞 또는 중간에 위치하지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo $PATH
    echo [5-END]
    echo [U-5]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'echo $PATH 의 결과: '$(echo $PATH | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'PATH 환경변수에 '.'이 맨 앞 또는 중간에 위치하므로 취약함'\" >> $RESULT_FILE 2>&1
    echo $PATH
    echo [5-END]
    echo [U-5]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-7]파일 및 디렉터리 소유자 설정
echo \"itemcode\"\: \"'U-07'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'파일 및 디렉터리 소유자 설정'\", >> $RESULT_FILE 2>&1
echo [7-START]
ls -lL /home | awk '{print $3}' | grep "^[0-9]" > tmp_6_1.txt
for i in `cat tmp_6_1.txt`; do ls -lLd /home/* | grep -w $i >> tmp_6_2.txt; done
if [ -f tmp_6_2.txt ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'/home 디렉토리에 소유자가 존재하지 않는 파일 검색의 결과: '$(cat tmp_6_2.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/home 디렉토리에 소유자가 존재하지 않는 파일이 존재하므로 취약함'\" >> $RESULT_FILE 2>&1
    cat tmp_6_2.txt
    echo [6-END]
    echo [U-6]Result : VULNERABLE
else
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'/home 디렉토리에 소유자가 존재하지 않는 파일 검색의 결과: '$(cat tmp_6_2.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/home 디렉토리에 소유자가 존재하지 않는 파일이 존재하지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [6-END]
    echo [U-6]Result : GOOD
fi
rm -rf tmp_6_1.txt
rm -rf tmp_6_2.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-8]/etc/passwd 파일 소유자 및 권한 설정
echo \"itemcode\"\: \"'U-08'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'/etc/passwd 파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [8-START]
if [ `ls -alL /etc/passwd | grep "^...-.--.--" | awk '$3=="root"' | wc -l` -eq 1 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ls -alL /etc/passwd 의 결과: '$(ls -alL /etc/passwd | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/passwd 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
    ls -alL /etc/passwd
    echo [7-END]
    echo [U-7]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ls -alL /etc/passwd 의 결과: '$(ls -alL /etc/passwd | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/passwd 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
    ls -alL /etc/passwd
    echo [7-END]
    echo [U-7]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-9]/etc/shadow 파일 소유자 및 권한 설정
echo \"itemcode\"\: \"'U-09'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'/etc/shadow 파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [9-START]
if [ `ls -alL /etc/shadow | grep "^....------" | awk '$3=="root"' | wc -l` -eq 1 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ls -alL /etc/shadow 의 결과: '$(ls -alL /etc/shadow | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/shadow 파일의 소유자(root) 및 퍼미션(400/600)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
    ls -alL /etc/shadow
    echo [8-END]
    echo [U-8]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ls -alL /etc/shadow 의 결과: '$(ls -alL /etc/shadow | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/shadow 파일의 소유자(root) 및 퍼미션(400/600)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
    ls -alL /etc/shadow
    echo [8-END]
    echo [U-8]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-10]/etc/hosts 파일 소유자 및 권한 설정
echo \"itemcode\"\: \"'U-10'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'/etc/hosts 파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [10-START]
if [ -f /etc/hosts ]
then
    if [ `ls -alL /etc/hosts | grep "^...-------" | awk '$3=="root"' | wc -l` -eq 1 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/hosts 의 결과: '$(ls -alL /etc/hosts | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/hosts 파일의 소유자(root) 및 퍼미션(600)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/hosts
	echo [9-END]
	echo [U-9]Result : GOOD
    else
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/hosts 의 결과: '$(ls -alL /etc/hosts | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/hosts 파일의 소유자(root) 및 퍼미션(600)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/hosts
	echo [9-END]
	echo [U-9]Result : VULNERABLE
    fi
else
    echo \"result\"\: 2, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ls -alL /etc/hosts 의 결과: '$(ls -alL /etc/hosts | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/hosts 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
    echo [9-END]
    echo [U-9]Result : N/A
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo "[U-11]/etc/(x)inetd.conf 파일 소유자 및 권한 설정"
echo \"itemcode\"\: \"'U-11'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'/etc/(x)inetd.conf 파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [11-START]
if [ -f /etc/xinetd.conf ]
then
    if [ `ls -alL /etc/xinetd.conf | grep "^....------" | awk '$3=="root"' | wc -l` -eq 1 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/xinetd.conf 의 결과: '$(ls -alL /etc/xinetd.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/xinetd.conf 파일의 소유자(root) 및 퍼미션(600)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/xinetd.conf
	echo [10-END]
	echo [U-10]Result : GOOD
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/xinetd.conf 의 결과: '$(ls -alL /etc/xinetd.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/xinetd.conf 파일의 소유자(root) 및 퍼미션(600)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/xinetd.conf
	echo [10-END]
	echo [U-10]Result : VULNERABLE
    fi
else
    if [ -f /etc/inetd.conf ]
    then
	if [ `ls -alL /etc/inetd.conf | grep "^....------" | awk '$3=="root"' | wc -l` -eq 1 ]
	then
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'ls -alL /etc/inetd.conf 의 결과: '$(ls -alL /etc/inetd.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'/etc/inetd.conf 파일의 소유자(root) 및 퍼미션(600)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	    ls -alL /etc/inetd.conf
	    echo [10-END]
	    echo [U-10]Result : GOOD
	else
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'ls -alL /etc/inetd.conf 의 결과: '$(ls -alL /etc/inetd.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'/etc/inetd.conf 파일의 소유자(root) 및 퍼미션(600)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	    ls -alL /etc/inetd.conf
	    echo [10-END]
	    echo [U-10]Result : VULNERABLE
	fi				
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/inetd.conf 의 결과: '$(ls -alL /etc/inetd.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/(x)inetd.conf 파일을 찾을 수 없으므로 양호함'\" >> $RESULT_FILE 2>&1
	echo [10-END]
	echo [U-10]Result : GOOD
    fi
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-12]/etc/syslog.conf 파일 소유자 및 권한 설정
echo \"itemcode\"\: \"'U-12'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'/etc/syslog.conf 파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [12-START]
if [ -f /etc/syslog.conf ]
then
    if [ `ls -alL /etc/syslog.conf | grep "^...-.--.--" | awk '$3=="root"' | wc -l` -eq 1 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/syslog.conf 의 결과: '$(ls -alL /etc/syslog.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/syslog.conf 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/syslog.conf
	echo [11-END]
	echo [U-11]Result : GOOD
    else
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/syslog.conf 의 결과: '$(ls -alL /etc/syslog.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/syslog.conf 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/syslog.conf
	echo [11-END]
	echo [U-11]Result : VULNERABLE
    fi
else
    if [ -f /etc/rsyslog.conf ]
    then
	if [ `ls -alL /etc/rsyslog.conf | grep "^...-.--.--" | awk '$3=="root"' | wc -l` -eq 1 ]
	then
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'ls -alL /etc/rsyslog.conf 의 결과: '$(ls -alL /etc/rsyslog.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'/etc/rsyslog.conf 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	    ls -alL /etc/rsyslog.conf
	    echo [11-END]
	    echo [U-11]Result : GOOD
	else
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'ls -alL /etc/rsyslog.conf 의 결과: '$(ls -alL /etc/rsyslog.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'/etc/rsyslog.conf 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	    ls -alL /etc/rsyslog.conf
	    echo [11-END]
	    echo [U-11]Result : VULNERABLE
	fi
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/rsyslog.conf 의 결과: '$(ls -alL /etc/rsyslog.conf | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/syslog.conf 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
	echo [11-END]
	echo [U-11]Result : N/A
    fi
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-13]/etc/services 파일 소유자 및 권한 설정
echo \"itemcode\"\: \"'U-13'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'/etc/services 파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [13-START]
if [ -f /etc/services ]
then
    if [ `ls -alL /etc/services | grep "^...-.--.--" | awk '$3=="root"' | wc -l` -eq 1 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/services 의 결과: '$(ls -alL /etc/services | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/services 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/services
	echo [12-END]
	echo [U-12]Result : GOOD
    else
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -alL /etc/services 의 결과: '$(ls -alL /etc/services | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/services 파일의 소유자(root) 및 퍼미션(644)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	ls -alL /etc/services
	echo [12-END]
	echo [U-12]Result : VULNERABLE
    fi
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ls -alL /etc/services 의 결과: '$(ls -alL /etc/services | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/services 파일이 없음'\", >> $RESULT_FILE 2>&1
    echo [12-END]
    echo [U-12]Result : N/A
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-14]SUID, SGID, Sticky bit 설정 파일 점검
echo \"itemcode\"\: \"'U-14'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'SUID, SGID, Sticky bit 설정 파일 점검'\", >> $RESULT_FILE 2>&1
echo [14-START]
FILES="/sbin/dump /usr/bin/lpq-lpd /usr/bin/newgrp /sbin/restore /usr/bin/lpr /usr/sbin/lpc /sbin/unix_chkpwd /usr/bin/lpr-lpd /usr/sbin/lpc-lpd /usr/bin/at /usr/bin/lprm /usr/sbin/traceroute /usr/bin/lpq /usr/bin/lprm-lpd"
for check_file in $FILES
do
    if [ -f $check_file ]
    then
	if [ -g $check_file -o -u $check_file ]
	then
	    echo `ls -alL $check_file` >> tmp_13.txt
	fi
    fi
done
if [ -f tmp_13.txt ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'SUID, SGID 검색 결과: '$(cat tmp_13.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'점검 파일 중 SUID, SGID가 설정된 파일이 존재하므로 취약함'\" >> $RESULT_FILE 2>&1
    cat tmp_13.txt
    echo [13-END]
    echo [U-13]Result : VULNERABLE
else
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'SUID, SGID 검색 결과: '$(cat tmp_13.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'점검 파일 중 SUID, SGID가 설정된 파일이 존재하지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [13-END]
    echo [U-13]Result : GOOD
fi
rm -rf tmp_13.txt
ls -al /sbin/dump /usr/bin/lpq-lpd /usr/bin/newgrp /sbin/restore /usr/bin/lpr /usr/sbin/lpc /sbin/unix_chkpwd /usr/bin/lpr-lpd /usr/sbin/lpc-lpd /usr/bin/at /usr/bin/lprm /usr/sbin/traceroute /usr/bin/lpq /usr/bin/lprm-lpd
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-15]사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정
echo \"itemcode\"\: \"'U-15'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [15-START]
if [ -f /etc/profile ]
then
    if [ `ls -alL /etc/profile | grep "^.....-..-." | awk '$3=="root"' | wc -l` -eq 1 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -al /etc/profile 의 결과: '$(ls -al /etc/profile | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/profile 파일의 소유자(root) 및 퍼미션(755)이 기준에 맞게 설정되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	ls -al /etc/profile
	echo [14-END]
	echo [U-14]Result : GOOD
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ls -al /etc/profile 의 결과: '$(ls -al /etc/profile | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/profile 파일의 소유자(root) 및 퍼미션(755)이 기준에 맞게 설정되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	ls -al /etc/profile
	echo [14-END]
	echo [U-14]Result : VULNERABLE
    fi
else
    echo \"result\"\: 2, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ls -al /etc/profile 의 결과: '$(ls -al /etc/profile | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/profile 파일이 없음'\" >> $RESULT_FILE 2>&1
    echo [14-END]
    echo [U-14]Result : N/A
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-16]world writable 파일 점검
echo \"itemcode\"\: \"'U-16'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'world writable 파일 점검'\", >> $RESULT_FILE 2>&1
echo [16-START]
find /etc -perm -2 -a -not -type l -ls > tmp_15.txt
if [ `cat tmp_15.txt | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'/etc 디렉토리 하위에 Others에 쓰기 권한이 부여된 파일 검색 결과: '$(cat tmp_15.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc 디렉토리 하위에 Others에 쓰기 권한이 부여된 파일이 존재하지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [15-END]
    echo [U-15]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'/etc 디렉토리 하위에 Others에 쓰기 권한이 부여된 파일 검색 결과: '$(cat tmp_15.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc 디렉토리 하위에 Others에 쓰기 권한이 부여된 파일이 존재하므로 취약함'\" >> $RESULT_FILE 2>&1
    cat tmp_15.txt
    echo [15-END]
    echo [U-15]Result : VULNERABLE
fi
rm -rf tmp_15.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo '[U-17]$HOME/.rhosts, hosts.equiv 사용 금지'
echo \"itemcode\"\: \"'U-17'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'$HOME/.rhosts, hosts.equiv 사용 금지'\", >> $RESULT_FILE 2>&1
echo [17-START]
ls -lL /home/ | grep -v "+found" | sed -n '2,$p' | awk '{print $9}' > tmp_17_1.txt
for i in `cat tmp_17_1.txt`; do ls -al /home/$i/.rhosts; done 2>/dev/null > tmp_17_2.txt
if [ -f /etc/hosts.equiv ]; then ls -lL /etc/hosts.equiv >> tmp_17_2.txt; else true; fi
if [ `cat tmp_17_2.txt | wc -l` -eq 0 ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'.rhosts, hosts.equiv 파일 검색의 결과: '$(0 | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'.rhosts, hosts.equiv 파일이 존재하지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [17-END]
    echo [U-17]Result : GOOD
else
    if [ `cat tmp_17_2.txt | wc -l` -eq `cat tmp_17_2.txt | grep "^....------" | wc -l` ]
    then
	for i in `cat tmp_17_2.txt | awk '{print $9}'`; do cat $i; done >> tmp_17_3.txt
	if [ `cat tmp_17_3.txt | grep "\+" | wc -l` -eq 0 ] 
	then
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'.rhosts, hosts.equiv 파일의 검색 결과: '$(cat tmp_17_3.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'.rhosts, hosts.equiv 파일의 퍼미션 및 설정이 기준에 맞게 적용되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	    for i in `cat tmp_17_2.txt | awk '{print $9}'`; do ls -lL $i; done
	    echo [17-END]
	    echo [U-17]Result : GOOD
	else
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'.rhosts, hosts.equiv 파일의 검색 결과: '$(cat tmp_17_3.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'.rhosts, hosts.equiv 파일의 설정이 기준에 맞지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	    for i in `cat tmp_17_2.txt | awk '{print $9}'`; do ls -lL $i; done
	    echo [17-END]
	    echo [U-17]Result : VULNERABLE
	fi
    else
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'.rhosts, hosts.equiv 파일의 검색 결과: '$(cat tmp_17_3.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'.rhosts, hosts.equiv 파일의 퍼미션이 기준에 맞지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	for i in `cat tmp_17_2.txt | awk '{print $9}'`; do ls -lL $i; done
	echo [17-END]
	echo [U-17]Result : VULNERABLE
    fi
fi
rm -rf tmp_17_1.txt
rm -rf tmp_17_2.txt				
rm -rf tmp_17_3.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-18]접속 IP 및 포트 제한
echo \"itemcode\"\: \"'U-18'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'접속 IP 및 포트 제한'\", >> $RESULT_FILE 2>&1
echo [18-START]
if [ -f /etc/hosts.deny ]
then
    if [ `cat /etc/hosts.deny | grep -v "#" | grep -iE "(sshd|all) *: *all$" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'cat /etc/hosts.deny 의 결과: '$(cat /etc/hosts.deny | grep -v "#" | tr '\n' ' '), 'cat /etc/hosts.allow 의 결과: '$(cat /etc/hosts.allow | grep -v "#" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/hosts.deny 파일에 Deny 설정이 존재하지 않으므로 취약함'\" >> $RESULT_FILE 2>&1
	ls -lL /etc/hosts.deny
	cat /etc/hosts.deny | grep -v "#"
	ls -lL /etc/hosts.allow
	cat /etc/hosts.allow | grep -v "#"
	echo [18-END]
	echo [U-18]Result : VULNERABLE
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'cat /etc/hosts.deny 의 결과: '$(cat /etc/hosts.deny | grep -v "#" | tr '\n' ' '), 'cat /etc/hosts.allow 의 결과: '$(cat /etc/hosts.allow | grep -v "#" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'/etc/hosts.deny 파일에 Deny 설정이 적용되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	ls -lL /etc/hosts.deny
	cat /etc/hosts.deny | grep -v "#"
	ls -lL /etc/hosts.allow
	cat /etc/hosts.allow | grep -v "#"
	echo [18-END]
	echo [U-18]Result : GOOD
    fi
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'cat /etc/hosts.deny 의 결과: '$(cat /etc/hosts.deny | grep -v "#" | tr '\n' ' '), 'cat /etc/hosts.allow 의 결과: '$(cat /etc/hosts.allow | grep -v "#" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'/etc/hosts.deny 파일이 존재하지 않음'\" >> $RESULT_FILE 2>&1
    echo [18-END]
    echo [U-18]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-19]cron 파일 소유자 및 권한 설정
echo \"itemcode\"\: \"'U-19'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'cron 파일 소유자 및 권한 설정'\", >> $RESULT_FILE 2>&1
echo [19-START]
ls -l /etc/* | egrep "cron.deny|cron.allow" > tmp_22_1.txt
if [ `cat tmp_22_1.txt | wc -l` -eq 0 ]
then
    echo \"result\"\: 3, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'cron.deny, cron.allow 파일 검색의 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'cron.deny, cron.allow 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
    echo [22-END]
    echo [U-22]Result : N/A
else
    cat tmp_22_1.txt | grep "^.....-----" > tmp_22_2.txt
    if [ `diff tmp_22_1.txt tmp_22_2.txt | wc -l` -eq 0 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'cron.deny, cron.allow 파일 확인의 결과: '$(cat tmp_22_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'cron 파일의 소유자(root) 및 퍼미션(640)이 기준에 맞게 적용되어 있으므로 양호함'\" >> $RESULT_FILE 2>&1
	cat tmp_22_1.txt
	echo [22-END]
	echo [U-22]Result : GOOD
    else
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'cron.deny, cron.allow 파일 확인의 결과: '$(cat tmp_22_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'cron 파일의 소유자(root) 및 퍼미션(640)이 기준에 맞게 적용되어 있지 않으므로 취약함'\" >> $RESULT_FILE 2>&1
	cat tmp_22_1.txt
	echo [22-END]
	echo [U-22]Result : VULNERABLE
    fi
fi	
rm -rf tmp_22_1.txt
rm -rf tmp_22_2.txt	
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-20]Finger 서비스 비활성화
echo \"itemcode\"\: \"'U-20'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'Finger 서비스 비활성화'\", >> $RESULT_FILE 2>&1
echo [20-START]
if [ `ps -ef | grep -i "finger" | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ps -ef | grep -i \"finger\" | grep -v \"grep\" 의 결과: '$(ps -ef | grep -i "finger" | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'Finger 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [19-END]
    echo [U-19]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ps -ef | grep -i \"finger\" | grep -v \"grep\" 의 결과: '$(ps -ef | grep -i "finger" | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'Finger 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    ps -ef | grep -i "finger" | grep -v "grep"
    echo [19-END]
    echo [U-19]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-21]Anonymous FTP 비활성화
echo \"itemcode\"\: \"'U-21'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'Anonymous FTP 비활성화'\", >> $RESULT_FILE 2>&1
echo [21-START]
if [ `ps -ef | grep -i "ftpd" | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ps -ef | grep -i \"ftpd\" | grep -v \"grep\" 의 결과: '$(ps -ef | grep -i "ftpd" | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'FTP 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [20-END]
    echo [U-20]Result : GOOD
elif [ `find /etc -name "vsftpd.conf" | wc -l` -gt 0 ]
then
    find /etc -name "vsftpd.conf" -exec cat {} \; > tmp_20_1.txt
    if [ `cat tmp_20_1.txt | grep -v "#" | grep "anonymous_enable" | grep -i -v "no$" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'vsftpd.conf anonymous_enable 검색의 결과: '$(cat tmp_20_1.txt | grep -v "#" | grep "anonymous_enable" | grep -i -v "no$" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'FTP 서비스가 실행중이며, Anonymous 접속이 차단되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	netstat -anp | grep ":21 " | grep -i "LISTEN"
	cat tmp_20_1.txt | grep "anonymous_enable"
	echo [20-END]
	echo [U-20]Result : GOOD
    else
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'vsftpd.conf anonymous_enable 검색의 결과: '$(cat tmp_20_1.txt | grep -v "#" | grep "anonymous_enable" | grep -i -v "no$" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'FTP 서비스가 실행중이며, Anonymous 접속이 허용되므로 취약함'\" >> $RESULT_FILE 2>&1
	netstat -anp | grep ":21 " | grep -i "LISTEN"
	cat tmp_20_1.txt | grep "anonymous_enable"
	echo [20-END]
	echo [U-20]Result : VULNERABLE
    fi
elif [ `find -L /etc -name "proftpd.conf" | wc -l` -gt 0 ]
then
    find /etc -name "proftpd.conf" -exec cat {} \; >> tmp_20_1.txt
    if [ `cat tmp_20_1.txt | grep -v "#" | grep -i "anonymous" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'proftdp.conf anonymous_enable 검색의 결과: '$(cat tmp_20_1.txt | grep -v "#" | grep -i "anonymous" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'FTP 서비스가 실행중이며, Anonymous 접속이 차단되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	cat tmp_20_1.txt | grep "anonymous"
	echo [20-END]
	echo [U-20]Result : GOOD
    else
	echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'proftdp.conf anonymous_enable 검색의 결과: '$(cat tmp_20_1.txt | grep -v "#" | grep -i "anonymous" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'FTP 서비스가 실행중이며, Anonymous 접속이 허용되므로 취약함'\" >> $RESULT_FILE 2>&1
	cat tmp_20_1.txt | grep -i "anonymous"
	echo [20-END]
	echo [U-20]Result : VULNERABLE
    fi
fi
cat tmp_20_1.txt | grep -v "#"
rm -rf tmp_20_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-22]r 계열 서비스 비활성화
echo \"itemcode\"\: \"'U-22'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'r 계열 서비스 비활성화'\", >> $RESULT_FILE 2>&1
echo [22-START]
SERVICE_INETD="rsh|rlogin|rexec"
systemctl list-units --type=service --state=running | egrep $SERVICE_INETD > tmp_21_1.txt
if [ `cat tmp_21_1.txt | wc -l` -eq 0 ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'r 계열 서비스 검색의 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'r 계열 서비스가 설치되어 있지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [21-END]
    echo [U-21]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'r 계열 서비스 검색의 결과: '$(cat tmp_21_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'r 계열 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    cat tmp_21_1.txt
    echo [21-END]
    echo [U-21]Result : VULNERABLE
fi
rm -rf tmp_21_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-23]DoS 공격에 취약한 서비스 비활성화
echo \"itemcode\"\: \"'U-23'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'DoS 공격에 취약한 서비스 비활성화'\", >> $RESULT_FILE 2>&1
echo [23-START]
SERVICE_INETD="echo|discard|daytime|chargen"
systemctl list-units --type=service --state=running | egrep $SERVICE_INETD > tmp_23_1.txt
if [ `cat tmp_23_1.txt | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'Dos공격에 취약한 서비스 검색의 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'DoS 공격에 취약한 서비스가 설치되어 있지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo "[서비스 목록] : echo, discard, daytime, charge"
    echo [23-END]
    echo [U-23]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'Dos공격에 취약한 서비스 검색의 결과: '$(cat tmp_23_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'DoS 공격에 취약한 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    cat tmp_23_1.txt
    echo [23-END]
    echo [U-23]Result : VULNERABLE
fi
rm -rf tmp_23_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-24]NFS 서비스 비활성화
echo \"itemcode\"\: \"'U-24'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'NFS 서비스 비활성화'\", >> $RESULT_FILE 2>&1
echo [24-START]
if [ `ps -ef | grep -i "nfs" | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'NFS 서비스 검색의 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'NFS 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [24-END]
    echo [U-24]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'NFS 서비스 검색의 결과: '$(ps -ef | grep -i "nfsd" | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'NFS 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    ps -ef | grep -i "nfsd" | grep -v "grep"
    echo [24-END]
    echo [U-24]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-25]NFS 접근통제
echo \"itemcode\"\: \"'U-25'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'NFS 접근통제'\", >> $RESULT_FILE 2>&1
echo [25-START]
if [ `ps -ef | grep -i "nfs" | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'NFS 서비스 검색의 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'NFS 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [25-END]
    echo [U-25]Result : GOOD
else
    if [ -f /etc/exports ]
    then
	if [ `cat /etc/exports | grep -i "everyone" | grep -v "^ *#" | wc -l` -eq 0 ]
	then
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'everyone 공유 검색의 결과: '$(cat /etc/exports | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'NFS 서비스가 실행중이나 everyone 공유가 존재하지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep -i "nfs" | grep -v "grep"
	    cat /etc/exports
	    echo [25-END]
	    echo [U-25]Result : GOOD
	else
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'everyone 공유 검색의 결과: '$(cat /etc/exports | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'NFS 서비스가 실행중이고 everyone 공유가 존재하므로 취약함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep -i "nfs" | grep -v "grep"
	    cat /etc/exports
	    echo [25-END]
	    echo [U-25]Result : VULNERABLE
	fi
    else
	echo \"result\"\: 2, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'/etc/export 검색의 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'NFS 서비스가 실행중이나 /etc/exports 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
	ps -ef | grep -i "nfs" | grep -v "grep"
	echo [25-END]
	echo [U-25]Result : MANUAL
    fi
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-26]automountd 제거
echo \"itemcode\"\: \"'U-26'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'automountd 제거'\", >> $RESULT_FILE 2>&1
echo [26-START]
if [ `ps -ef | grep -i "automountd" | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ps -ef | grep -i \"automountd\" | grep -v \"grep\" 의 결과: '$(ps -ef | grep -i "automountd" | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'automountd 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [26-END]
    echo [U-26]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ps -ef | grep -i \"automountd\" | grep -v \"grep\" 의 결과: '$(ps -ef | grep -i "automountd" | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'automountd 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    ps -ef | grep -i "automountd" | grep -v "grep"
    echo [26-END]
    echo [U-26]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-27]RPC 서비스 확인
echo \"itemcode\"\: \"'U-27'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'RPC 서비스 확인'\", >> $RESULT_FILE 2>&1
echo [27-START]
SERVICE_RPC="rpc.cmsd|rpc.ttdbserverd|sadmind|rusersd|walld|sprayd|rstatd|rpc.nisd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd|rexd"
systemctl list-units --type=service --state=running | egrep $SERVICE_RPC > tmp_27_1.txt
if [ `cat tmp_27_1.txt | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'RPC 서비스 검색의 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'RPC 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [27-END]
    echo [U-27]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'RPC 서비스 검색의 결과: '$(cat tmp_27_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'RPC 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    cat tmp_27_1.txt
    echo [27-END]
    echo [U-27]Result : VULNERABLE
fi
rm -rf tmp_27_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-28]NIS, NIS+ 점검
echo \"itemcode\"\: \"'U-28'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'NIS, NIS+ 점검'\", >> $RESULT_FILE 2>&1
echo [28-START]
SERVICE_NIS="ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|rpc.nisd"
if [ `ps -ef | egrep $SERVICE_NIS | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'NIS, NIS+ 서비스 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'NIS 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [28-END]
    echo [U-28]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'NIS, NIS+ 서비스 검색 결과: '$(ps -ef | egrep $SERVICE_NIS | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'NIS 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    ps -ef | egrep $SERVICE_NIS | grep -v "grep"
    echo [28-END]
    echo [U-28]Result : VULNERABLE
fi
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-29]tftp, talk 서비스 비활성화
echo \"itemcode\"\: \"'U-29'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'tftp, talk 서비스 비활성화'\", >> $RESULT_FILE 2>&1
echo [29-START]
SERVICE_INETD="tftp|talk"
systemctl list-units --type=service --state=running | egrep $SERVICE_INETD > tmp_29_1.txt
if [ `cat tmp_29_1.txt | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'tftp, talk 서비스 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'tftp, talk 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [29-END]
    echo [U-29]Result : GOOD
else
    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'tftp, talk 서비스 검색 결과: '$(cat tmp_29_1.txt | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'tftp, talk 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
    cat tmp_29_1.txt
    echo [29-END]
    echo [U-29]Result : VULNERABLE
fi
rm -rf tmp_29_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-30]Sendmail 버전 점검
echo \"itemcode\"\: \"'U-30'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'Sendmail 버전 점검'\", >> $RESULT_FILE 2>&1
echo [30-START]
if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ps -ef | grep sendmail | grep -v \"grep\" 의 결과: '$(ps -ef | grep sendmail | grep -v "grep" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'Sendmail 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [30-END]
    echo [U-30]Result : GOOD
else
    if [ `find /etc -name "sendmail.cf" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 2, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'sendmail.cf 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'Sendmail 서비스가 실행중이나 sendmail.cf 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
	ps -ef | grep sendmail | grep -v "grep"
	echo [30-END]
	echo [U-30]Result : MANUAL
    else
	find /etc -name "sendmail.cf" -exec cat {} > tmp_30_1.txt \;			
	if [ `cat tmp_30_1.txt | grep -v '^ *#' | grep DZ | egrep "8.14" | wc -l` -eq 0 ]
	then
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'Sendmail 버전 확인 결과: '$(cat tmp_30_1.txt | grep -v '^ *#' | grep DZ | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'취약한 버전의 Sendmail 서비스가 실행중이므로 취약함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep sendmail | grep -v "grep"
	    echo "Sendmail 버전 : `cat tmp_30_1.txt | grep -v '^ *#' | grep DZ`"
	    echo [30-END]
	    echo [U-30]Result : VULNERABLE
	else
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'Sendmail 버전 확인 결과: '$(cat tmp_30_1.txt | grep -v '^ *#' | grep DZ | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'취약하지 않은 버전의 Sendmail 서비스가 실행중이므로 양호함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep sendmail | grep -v "grep"
	    echo "Sendmail 버전 : `cat tmp_30_1.txt | grep -v '^ *#' | grep DZ`"
	    echo [30-END]
	    echo [U-30]Result : GOOD
	fi
    fi
fi
rm -rf tmp_30_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-31]스팸 메일 릴레이 제한
echo \"itemcode\"\: \"'U-31'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'스팸 메일 릴레이 제한'\", >> $RESULT_FILE 2>&1
echo [31-START]
if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'Sendmail 서비스 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'Sendmail 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [31-END]
    echo [U-31]Result : GOOD
else
    if [ `find /etc -name "sendmail.cf" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 2, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'sendmail.cf 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'Sendmail 서비스가 실행중이나 sendmail.cf 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
	ps -ef | grep sendmail | grep -v "grep"
	echo [31-END]
	echo [U-31]Result : MANUAL
    else
	find /etc -name "sendmail.cf" -exec cat {} > tmp_31_1.txt \;
	if [ `cat tmp_31_1.txt | grep -v "^ *#" | grep "R$\*" | grep -i "Relaying denied" | wc -l ` -gt 0 ]
	then
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'Sendmail 설정 검색 결과: '$(cat tmp_31_1.txt | grep -v "^ *#" | grep "R$\*" | grep -i "Relaying denied" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'스팸 메일 릴레이 제한 설정이 적용되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep sendmail | grep -v "grep"
	    cat tmp_31_1.txt | grep -v "^ *#" | grep "R$\*" | grep -i "Relaying denied"
	    echo [31-END]
	    echo [U-31]Result : GOOD
	else
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'Sendmail 설정 검색 결과: '$(cat tmp_31_1.txt | grep -v "^ *#" | grep "R$\*" | grep -i "Relaying denied" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'스팸 메일 릴레이 제한 설정이 적용되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep sendmail | grep -v "grep"
	    cat tmp_31_1.txt | grep "R$\*" | grep -i "Relaying denied"
	    echo [31-END]
	    echo [U-31]Result : VULNERABLE
	fi
    fi
fi
rm -rf tmp_31_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-32]일반사용자의 Sendmail 실행 방지
echo \"itemcode\"\: \"'U-32'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'일반사용자의 Sendmail 실행 방지'\", >> $RESULT_FILE 2>&1
echo [32-START]
if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'Sendmail 서비스 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'Sendmail 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    echo [32-END]
    echo [U-32]Result : GOOD
else
    if [ `find /etc -name "sendmail.cf" | wc -l` -eq 0 ]
    then
	echo \"result\"\: 2, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'sendmail.cf 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'Sendmail 서비스가 실행중이나 sendmail.cf 파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
	ps -ef | grep sendmail | grep -v "grep"
	echo [32-END]
	echo [U-32]Result : MANUAL
    else
	find /etc -name "sendmail.cf" -exec cat {} > tmp_32_1.txt \;
	if [ `cat tmp_32_1.txt | grep -i "O PrivacyOptions" | grep -i "restrictqrun" | grep -v "#" | wc -l` -gt 0 ]
	then
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'Sendmail 설정 검색 결과: '$(cat tmp_32_1.txt | grep -i "O PrivacyOptions" | grep -i "restrictqrun" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'일반사용자의 Sendmail 실행 방지 설정이 적용되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep sendmail | grep -v "grep"
	    cat tmp_32_1.txt | grep -i "O PrivacyOptions" | grep -i "restrictqrun"
	    echo [32-END]
	    echo [U-32]Result : GOOD
	else
	    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'Sendmail 설정 검색 결과: '$(cat tmp_32_1.txt | grep -i "O PrivacyOptions" | grep -i "restrictqrun" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'일반사용자의 Sendmail 실행 방지 설정이 적용되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	    ps -ef | grep sendmail | grep -v "grep"
	    cat tmp_32_1.txt | grep -i "O PrivacyOptions" | grep -i "restrictqrun"
	    echo [32-END]
	    echo [U-32]Result : VULNERABLE
	fi
    fi
fi
rm -rf tmp_32_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-33]DNS 보안 버전 패치
echo \"itemcode\"\: \"'U-33'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'DNS 보안 버전 패치'\", >> $RESULT_FILE 2>&1
echo [33-START]
if [ `ss -anp | awk '{print $5}' | grep -v 127.0.0 | grep ":53$" | wc -l` -eq 0 ]; then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ss -anp | awk {print $5} | grep -v 127.0.0 | grep \":53$\"의 결과: '$(ss -anp | awk '{print $5}' | grep -v 127.0.0 | grep ":53$" | grep "Active:" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'DNS 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    systemctl status bind9 | grep "Active:"
    echo [33-END]
    echo [U-33]Result : GOOD
else
    echo \"result\"\: 2, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'named -v 의 결과: '$(named -v | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'DNS 서비스가 실행중이며 버전을 확인하여 결과 분석'\" >> $RESULT_FILE 2>&1
    systemctl status bind9 | grep "Active:"
    ss -anp | awk '{print $5}' | grep -v 127.0.0 | grep ":53$"
    named -v
    echo [33-END]
    echo [U-33]Result : MANUAL
fi		
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-34]DNS ZoneTransfer 설정
echo \"itemcode\"\: \"'U-34'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'DNS ZoneTransfer 설정'\", >> $RESULT_FILE 2>&1
echo [34-START]
if [ `ss -anp | awk '{print $5}' | grep -v 127.0.0 | grep ":53$" | wc -l` -eq 0 ]
then
    echo \"result\"\: 0, >> $RESULT_FILE 2>&1
    echo \"codedetail\"\: \"'ss -anp | awk {print $5} | grep -v 127.0.0 | grep \":53$\"의 결과: '$(ss -anp | awk '{print $5}' | grep -v 127.0.0 | grep ":53$" | grep "Active:" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
    echo \"resultdetail\"\: \"'DNS 서비스가 실행중이지 않으므로 양호함'\" >> $RESULT_FILE 2>&1
    systemctl status bind9 | grep "Active:"
    echo [34-END]
    echo [U-34]Result : GOOD
else
    cat /etc/bind/named.conf.options | grep -v "/" > tmp_34_1.txt 2> /dev/null
    if [ `cat tmp_34_1.txt | wc -l` -eq 0 ]
    then
	echo \"result\"\: 2, >> $RESULT_FILE 2>&1
	echo \"codedetail\"\: \"'ss -anp | awk {print $5} | grep -v 127.0.0 | grep \":53$\"의 결과: '$(ss -anp | awk '{print $5}' | grep -v 127.0.0 | grep ":53$" | grep "Active:" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	echo \"resultdetail\"\: \"'DNS 서비스가 실행중이나 설정파일을 찾을 수 없음'\" >> $RESULT_FILE 2>&1
	ss -anp | awk '{print $5}' | grep ":53$"
	echo [34-END]
	echo [U-34]Result : MANUAL
    else
	if [ `cat tmp_34_1.txt | grep "allow-transfer" | grep "none" | wc -l` -eq 0 ]
	then
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'DNS ZoneTransfer 설정 검색 결과: '$(: | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'DNS 서비스가 실행중이며 DNS ZoneTransfer 설정이 적용되지 않았으므로 취약함'\" >> $RESULT_FILE 2>&1
	    cat tmp_34_1.txt
	    echo [34-END]
	    echo [U-34]Result : VULNERABLE
	else
	    echo \"result\"\: 1, >> $RESULT_FILE 2>&1
	    echo \"codedetail\"\: \"'DNS ZoneTransfer 설정 검색 결과: '$(cat tmp_34_1.txt | grep "allow-transfer" | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
	    echo \"resultdetail\"\: \"'DNS 서비스가 실행중이며 DNS ZoneTransfer 설정이 적용되었으므로 양호함'\" >> $RESULT_FILE 2>&1
	    
	    ss -anp | awk '{print $5}' | grep ":53$"
	    cat tmp_34_1.txt | grep "allow-transfer"
	    echo [34-END]
	    echo [U-34]Result : GOOD
	fi
    fi
fi
rm -rf tmp_34_1.txt
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-35]최신 보안패치 및 벤더 권고사항 적용
echo \"itemcode\"\: \"'U-35'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'최신 보안패치 및 벤더 권고사항 적용'\", >> $RESULT_FILE 2>&1
echo [35-START]
echo \"result\"\: 2, >> $RESULT_FILE 2>&1
echo \"codedetail\"\: \"'uname -a 의 결과: '$(uname -a | tr '\n' ' ')\", >> $RESULT_FILE 2>&1
echo \"resultdetail\"\: \"'취약점 점검 가이드를 참고하시어 발표된 중 현재 사용 중인 프로그램의 보안 관련 Update 찾아 해당 Update Download'\" >> $RESULT_FILE 2>&1
uname -a
echo [42-END]
echo [U-42]Result : MANUAL
echo \}, >> $RESULT_FILE 2>&1

echo \{ >> $RESULT_FILE 2>&1
echo [U-36]로그의 정기적 검토 및 보고
echo \"itemcode\"\: \"'U-36'\", >> $RESULT_FILE 2>&1
echo \"importance\"\: 1, >> $RESULT_FILE 2>&1
echo \"title\"\: \"'로그의 정기적 검토 및 보고'\", >> $RESULT_FILE 2>&1
echo [36-START]
echo \"result\"\: 2, >> $RESULT_FILE 2>&1
echo \"codedetail\"\: \"'var/log 또는 var/adm 확인'\", >> $RESULT_FILE 2>&1
echo \"resultdetail\"\: \"'취약점 점검 가이드를 참고하시어 로그 기록의 검토 분석 리포트 작성 및 보고 등이 정기적으로 이루어지고 있는지 점검'\" >> $RESULT_FILE 2>&1
echo [43-END]
echo [U-43]Result : MANUAL

echo '}' >> $RESULT_FILE 2>&1
echo ']' >> $RESULT_FILE 2>&1
echo '}' >> $RESULT_FILE 2>&1

