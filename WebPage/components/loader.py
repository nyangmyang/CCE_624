
# ══════════════════════════════════════════════════════════════════════════════
# 📦 필수 라이브러리 import
# ══════════════════════════════════════════════════════════════════════════════
import json                     # JSON 파일 파싱용
from datetime import datetime   # 날짜/시간 처리용
from pathlib import Path       # 파일 경로 처리용 (크로스 플랫폼 호환)
from typing import List, Dict  # 타입 힌팅용

import pandas as pd           # DataFrame 조작용
import streamlit as st       # 캐싱 및 UI 메시지 표시용

import sys
import os

import random

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from db_test import TestManager

# ══════════════════════════════════════════════════════════════════════════════
# 🗂️ 파일 경로 설정 (실제 폴더 구조에 맞게 수정)
# ══════════════════════════════════════════════════════════════════════════════

# 현재 loader.py 파일의 절대 경로 구하기
# webPage/WebPage/components/loader.py
BASE_DIR = Path(__file__).resolve().parent

# result 폴더 경로 설정 - 실제 구조에 맞게 수정
# webPage/WebPage/components/ → webPage/result/ 로 가려면 ../../result
RESULT_DIR = (BASE_DIR / "../../result").resolve()

# ══════════════════════════════════════════════════════════════════════════════
# 🗂️ 네비게이션바 실시간 연동 
# ══════════════════════════════════════════════════════════════════════════════


def check_connection():
    """실제 DB 연결 상태 체크"""
    try:
        # DB 연결 테스트 (간단한 쿼리 실행)
        raw_data = load_test_result()
        return len(raw_data) > 0  # 데이터가 있으면 연결 성공
    except:
        return False

def get_loaded_modules():
    """현재 로딩된 모듈 목록 반환"""
    import sys
    return list(sys.modules.keys())

def get_db_stats():
    """DB 통계 정보 반환"""
    try:
        raw_data = load_test_result()
        return {
            'total_records': len(raw_data),
            'last_updated': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'data_sources': ['vulnerability_scan', 'security_check']  # 실제 테이블명
        }
    except:
        return {'total_records': 0, 'last_updated': 'N/A', 'data_sources': []}

# ══════════════════════════════════════════════════════════════════════════════
# 📋 데이터 변환 매핑 테이블
# ══════════════════════════════════════════════════════════════════════════════

# 점검 결과 코드 → 한글 변환 테이블
# JSON에서 오는 숫자 코드를 사용자가 이해하기 쉬운 한글로 변환
RESULT_MAP = {
    0: "양호",        # 보안 기준을 만족하는 경우
    1: "취약",        # 보안 위험이 있는 경우
    2: "해당없음"     # 해당 점검 항목이 적용되지 않는 경우
}

# 중요도 코드 → 한글 변환 테이블
# 취약점의 심각도를 나타내는 숫자를 한글로 변환
IMPORTANCE_MAP = {
    1: "낮음",        # 낮은 위험도 (예: 정보 노출)
    2: "보통",        # 중간 위험도 (예: 권한 상승)
    3: "높음"         # 높은 위험도 (예: 시스템 침해)
}

# 🏷️ 보안 점검 항목 자동 카테고리 분류 규칙
# 점검 항목 제목에 포함된 키워드를 기반으로 카테고리 자동 분류
# 예: "계정 잠금 설정" → "계정 관리" 카테고리로 분류
CATEGORY_RULES = {
    "패스워드 정책": ["password", "passwd", "패스워드", "암호", "비밀번호"],
    "계정 관리": ["account", "계정", "user", "사용자", "로그인"],
    "서비스 관리": ["service", "서비스", "daemon", "프로세스"],
    "네트워크 보안": ["network", "네트워크", "port", "포트", "방화벽"],
    "파일 시스템": ["file", "파일", "directory", "디렉토리", "권한"],
    "로그 관리": ["log", "로그", "audit", "감사", "기록"],
}

# 💡 사용법 예시:
# - JSON에서 result: 1 → RESULT_MAP[1] → "취약"
# - JSON에서 importance: 3 → IMPORTANCE_MAP[3] → "높음"
# - 제목에 "패스워드"가 들어있으면 → "패스워드 정책" 카테고리로 분류

def load_test_result():
    db_config = {
        'host': 'localhost',
        'user': 'nyangnyang',
        'password': '0000',
        'database': 'itsec_01'
    }

    test_manager = TestManager(db_config)

    test_result = []
    test_result = test_manager.list_test_latest_by_host();

    return test_result

# ══════════════════════════════════════════════════════════════════════════════
# 📥 JSON 파일 로딩
# ══════════════════════════════════════════════════════════════════════════════
@st.cache_data(ttl=600, show_spinner=False)
def load_json_files() -> List[Dict]:
    """
    📁 result 폴더의 모든 JSON 파일을 로드하여 리스트로 반환
    
    이 함수는 보안 점검 도구가 생성한 JSON 결과 파일들을 모두 읽어서
    하나의 리스트로 합쳐 반환합니다. Streamlit 캐싱으로 10분간 결과를 저장하여
    같은 데이터를 반복해서 읽지 않도록 성능을 최적화합니다.
    
    📂 처리 과정:
    1. result 폴더 존재 여부 확인
    2. *.json 패턴으로 모든 JSON 파일 검색
    3. 각 파일을 UTF-8 인코딩으로 읽어서 JSON 파싱
    4. 파싱 오류 발생시 해당 파일만 건너뛰고 계속 진행
    
    Returns:
        List[Dict]: JSON 파일들의 데이터를 담은 리스트
                   빈 리스트면 로드할 파일이 없거나 모두 오류
        
    Examples:
        >>> data = load_json_files()
        >>> print(f"로드된 파일 수: {len(data)}")
        로드된 파일 수: 5
        
        >>> # 첫 번째 파일의 구조 확인
        >>> if data:
        >>>     print(data[0].keys())
        dict_keys(['targetip', 'testedtime', 'osinfo', 'result'])
    
    ⚠️ 주의사항:
        - result 폴더가 없으면 경고 메시지와 함께 빈 리스트 반환
        - JSON 파일이 없어도 경고 메시지와 함께 빈 리스트 반환
        - 개별 파일 파싱 오류시 오류 메시지 표시하고 해당 파일만 제외
    """
    # 1단계: result 폴더 존재 여부 확인
    if not RESULT_DIR.exists():
        st.warning(f"⚠️ result 폴더가 없습니다: {RESULT_DIR}")
        return []

    # 2단계: JSON 파일 목록 검색
    json_paths = list(RESULT_DIR.glob("*.json"))
    if not json_paths:
        st.warning("⚠️ result 폴더에 JSON 파일이 없습니다.")
        return []

    # 3단계: 각 JSON 파일 읽기 및 파싱
    data = []
    successful_files = 0
    
    for path in json_paths:
        try:
            # UTF-8 인코딩으로 파일 읽기
            content = json.loads(path.read_text(encoding="utf-8"))
            data.append(content)
            successful_files += 1
            
        except json.JSONDecodeError as err:
            # JSON 형식 오류 (예: 문법 오류, 잘못된 구조)
            st.error(f"❌ {path.name} JSON 파싱 오류: {err}")
            
        except UnicodeDecodeError as err:
            # 인코딩 오류 (예: 한글 깨짐)
            st.error(f"❌ {path.name} 인코딩 오류: {err}")
            
        except Exception as err:
            # 기타 예상치 못한 오류
            st.error(f"❌ {path.name} 읽기 오류: {err}")
    
    # 4단계: 결과 요약 정보 표시
    if successful_files > 0:
        st.info(f"📁 {successful_files}개의 JSON 파일을 성공적으로 로드했습니다.")
    
    return data

# ══════════════════════════════════════════════════════════════════════════════
# 🔄 DataFrame 변환 및 전처리
# ══════════════════════════════════════════════════════════════════════════════
def preprocess_data() -> pd.DataFrame:
    """
    🔄 JSON 데이터를 분석용 DataFrame으로 변환하고 전처리 수행
    
    이 함수는 보안 점검 결과의 핵심 변환 로직을 담당합니다.
    raw JSON 데이터를 받아서 분석하기 쉬운 테이블 형태로 변환하고,
    추가적인 파생 컬럼들을 생성하여 대시보드에서 활용할 수 있게 만듭니다.
    
    🔄 처리 과정:
    1. load_json_files()로 raw JSON 데이터 로드
    2. 각 JSON 파일의 메타데이터 추출 (IP, 시간, OS)
    3. result 배열의 각 점검 항목을 개별 레코드로 변환
    4. 자동 분류: 카테고리, 부서, PC명 등 파생 컬럼 생성
    5. DataFrame으로 조합 및 반환
    
    📊 생성되는 컬럼 설명:
    - PC명: IP 기반 생성 (예: "PC-100")
    - 점검항목: 보안 점검 항목명 (예: "계정 잠금 정책 설정")
    - 진단시점: 점검 실행 시간 (datetime 객체)
    - 확인결과: "양호", "취약", "해당없음" 중 하나
    - 위험도: "낮음", "보통", "높음" 중 하나
    - 조치방법: 취약점 발견시 권장 조치사항
    - 카테고리: 자동 분류된 보안 카테고리 (예: "계정 관리")
    - 부서: IP 기반 부서 분류 (예: "개발팀")
    - OS: 운영체제 정보
    - [원본 데이터]: 진단코드, 중요도_원본, 점검결과_원본 (디버깅용)
    
    Returns:
        pd.DataFrame: 전처리된 보안 점검 데이터
                     데이터가 없으면 빈 DataFrame 반환
        
    Examples:
        >>> df = preprocess_data()
        >>> print(df.columns.tolist())
        ['PC명', '점검항목', '진단시점', '확인결과', '위험도', '조치방법', 
         '카테고리', '부서', 'OS', '진단코드', '중요도_원본', '점검결과_원본']
         
        >>> print(f"총 {len(df)}개 점검 항목 로드")
        총 1,247개 점검 항목 로드
        
        >>> # 결과 분포 확인
        >>> print(df['확인결과'].value_counts())
        양호      856
        취약      301
        해당없음   90
    """
    # 1단계: Raw JSON 데이터 로드
    raw_json = load_json_files()
    if not raw_json:
        # JSON 파일이 없거나 로드 실패시 빈 DataFrame 반환
        return pd.DataFrame()

    # 2단계: 레코드 리스트 초기화 (각 점검 항목이 하나의 레코드가 됨)
    records = []
    
    # 3단계: 각 JSON 파일 처리
    for blob in raw_json:
        # 3-1. JSON 파일의 메타데이터 추출
        target_ip = blob.get("targetip", "Unknown")      # 점검 대상 서버 IP
        tested_time = blob.get("testedtime", "Unknown")  # 점검 실행 시간
        os_info = blob.get("osinfo", "Unknown")          # 운영체제 정보

        # 3-2. 각 점검 항목을 개별 레코드로 변환
        for item in blob.get("result", []):
            # 하나의 점검 항목을 DataFrame의 한 행으로 변환
            record = {
                # 🏷️ 사용자 친화적 컬럼들 (분석/시각화용)
                "PC명": generate_pc_name(target_ip),        # "PC-100" 형태로 변환
                "점검항목": item.get("title", "N/A"),         # 점검 항목명
                "진단시점": parse_timestamp(tested_time),    # datetime 객체로 변환
                "확인결과": RESULT_MAP.get(item.get("result"), "알수없음"),    # 숫자 → 한글
                "위험도": IMPORTANCE_MAP.get(item.get("importance"), "알수없음"), # 숫자 → 한글
                "조치방법": item.get("resultdetail", "N/A"), # 조치 방법 상세
                "카테고리": classify_category(item.get("title", "")),  # 자동 카테고리 분류
                "부서": classify_department(target_ip),      # IP 기반 부서 분류
                "OS": os_info,                              # 운영체제 정보
                
                # 🔧 원본 데이터 보존 (디버깅 및 상세 분석용)
                "진단코드": item.get("itemcode", "N/A"),     # 점검 코드 (예: "U-01")
                "중요도_원본": item.get("importance", 0),    # 원본 중요도 숫자
                "점검결과_원본": item.get("result", 0),      # 원본 결과 숫자
            }
            records.append(record)

    # 4단계: 레코드 리스트를 pandas DataFrame으로 변환
    df = pd.DataFrame(records)
    
    # 5단계: 성공 메시지 표시 (Streamlit UI에서 확인 가능)
    if not df.empty:
        st.toast(f"✅ {len(df)}개 항목 로드 완료", icon="✅")
        
        # 추가 정보: PC 수와 점검 기간 표시
        unique_pcs = df["PC명"].nunique()
        date_range = f"{df['진단시점'].min().date()} ~ {df['진단시점'].max().date()}"
        st.info(f"📊 {unique_pcs}대 서버, 점검 기간: {date_range}")
    
    return df

# ══════════════════════════════════════════════════════════════════════════════
# 🛠️ 헬퍼 함수들
# ══════════════════════════════════════════════════════════════════════════════

def parse_timestamp(timestamp_str: str) -> datetime:
    """
    타임스탬프 문자열을 datetime 객체로 변환
    
    Args:
        timestamp_str (str): 타임스탬프 문자열 (예: "2025-06-20 14:30:00")
        
    Returns:
        datetime: 변환된 datetime 객체
        
    Examples:
        >>> dt = parse_timestamp("2025-06-20 14:30:00")
        >>> print(dt.strftime("%Y-%m-%d"))
        2025-06-20
    """
    if timestamp_str == "Unknown":
        return datetime.now()
    
    try:
        return datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        # 다양한 날짜 형식 시도
        for fmt in ["%Y-%m-%d", "%Y/%m/%d %H:%M:%S", "%Y-%m-%d %H:%M"]:
            try:
                return datetime.strptime(timestamp_str, fmt)
            except ValueError:
                continue
        
        # 모든 형식 실패시 현재 시간 반환
        st.warning(f"⚠️ 날짜 형식을 인식할 수 없습니다: {timestamp_str}")
        return datetime.now()

def generate_pc_name(ip: str) -> str:
    """
    IP 주소로부터 PC명 생성
    
    Args:
        ip (str): IP 주소 (예: "192.168.1.100")
        
    Returns:
        str: PC명 (예: "PC-100")
        
    Examples:
        >>> pc_name = generate_pc_name("192.168.1.100")
        >>> print(pc_name)
        PC-100
    """
    if ip == "Unknown":
        return "PC-Unknown"
    
    try:
        last_octet = ip.split(".")[-1]
        return f"PC-{last_octet}"
    except (IndexError, AttributeError):
        return "PC-Unknown"

def classify_category(title: str) -> str:
    """
    점검 항목 제목으로부터 카테고리 분류
    
    Args:
        title (str): 점검 항목 제목
        
    Returns:
        str: 분류된 카테고리명
        
    Examples:
        >>> category = classify_category("계정 잠금 정책 설정")
        >>> print(category)
        계정 관리
    """
    if not title:
        return "기타 보안"
    
    title_lower = title.lower()
    
    for category, keywords in CATEGORY_RULES.items():
        if any(keyword in title_lower for keyword in keywords):
            return category
    
    return "기타 보안"

def classify_department(ip: str) -> str:
    """
    IP 주소로부터 부서 분류
    
    Args:
        ip (str): IP 주소
        
    Returns:
        str: 부서명
        
    Examples:
        >>> dept = classify_department("192.168.1.25")
        >>> print(dept)
        개발팀
    """
    if ip == "Unknown":
        return "알수없음"
    
    try:
        last_octet = int(ip.split(".")[-1])
        
        if last_octet <= 50:
            return "개발팀"
        elif last_octet <= 100:
            return "운영팀"
        elif last_octet <= 150:
            return "보안팀"
        else:
            return "관리팀"
            
    except (ValueError, IndexError):
        return "기타"

# ══════════════════════════════════════════════════════════════════════════════
# 📊 데이터 검증 및 품질 체크
# ══════════════════════════════════════════════════════════════════════════════
def validate_data(df: pd.DataFrame) -> Dict[str, any]:
    """
    데이터 품질 검증 및 통계 정보 반환
    
    Args:
        df (pd.DataFrame): 검증할 DataFrame
        
    Returns:
        Dict: 데이터 품질 정보
        
    Examples:
        >>> info = validate_data(df)
        >>> print(f"총 레코드 수: {info['total_records']}")
    """
    if df.empty:
        return {"valid": False, "message": "데이터가 비어있습니다"}
    
    # 기본 통계
    total_records = len(df)
    unique_pcs = df["PC명"].nunique()
    date_range = (df["진단시점"].min(), df["진단시점"].max())
    
    # 데이터 품질 체크
    missing_data = df.isnull().sum()
    duplicate_records = df.duplicated().sum()
    
    # 결과 분포
    result_distribution = df["확인결과"].value_counts().to_dict()
    importance_distribution = df["위험도"].value_counts().to_dict()
    
    return {
        "valid": True,
        "total_records": total_records,
        "unique_pcs": unique_pcs,
        "date_range": date_range,
        "missing_data": missing_data.to_dict(),
        "duplicate_records": duplicate_records,
        "result_distribution": result_distribution,
        "importance_distribution": importance_distribution,
    }

# ══════════════════════════════════════════════════════════════════════════════
# 🚀 메인 인터페이스 함수
# ══════════════════════════════════════════════════════════════════════════════
def load_data() -> pd.DataFrame:
    """
    메인 데이터 로딩 함수 - 외부에서 사용하는 주요 인터페이스
    
    Returns:
        pd.DataFrame: 로드되고 전처리된 보안 점검 데이터
        
    Examples:
        >>> # 다른 모듈에서 사용
        >>> from loader import load_data
        >>> df = load_data()
        >>> print(f"로드된 데이터: {len(df)}개 레코드")
    """
    return preprocess_data()

def get_data_info() -> Dict[str, any]:
    """
    데이터 정보 및 품질 리포트 반환
    
    Returns:
        Dict: 데이터 품질 정보
        
    Examples:
        >>> info = get_data_info()
        >>> if info['valid']:
        >>>     print(f"데이터 로드 성공: {info['total_records']}개")
    """
    df = load_data()
    return validate_data(df)

# ══════════════════════════════════════════════════════════════════════════════
# 🧪 테스트 및 디버깅 함수
# ══════════════════════════════════════════════════════════════════════════════
def debug_json_structure():
    """
    JSON 파일 구조 디버깅 - 개발용
    """
    raw_data = load_json_files()
    if raw_data:
        sample = raw_data[0]
        st.write("### JSON 구조 샘플")
        st.json(sample)
        
        if "result" in sample and sample["result"]:
            st.write("### 점검 항목 샘플")
            st.json(sample["result"][0])

if __name__ == "__main__":
    # 모듈 테스트
    print("🔍 loader.py 모듈 테스트")
    df = load_test_result()
    print(df)
    
    # df = load_data()
    # info = get_data_info()
    
    # if info["valid"]:
    #     print(f"✅ 데이터 로드 성공")
    #     print(f"   - 총 레코드: {info['total_records']}개")
    #     print(f"   - PC 수: {info['unique_pcs']}대")
    #     print(f"   - 결과 분포: {info['result_distribution']}")
    # else:
    #     print(f"❌ 데이터 로드 실패: {info['message']}")
