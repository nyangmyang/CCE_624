from __future__ import annotations

import importlib
from functools import lru_cache
from types import ModuleType
from typing import Dict

import streamlit as st
import mysql.connector
from mysql.connector import Error
import sys
import os
from datetime import datetime
from pathlib import Path

# ────────────────────────────────────────────────────────────────────────────── 
# 🚨 중요: set_page_config는 가장 먼저 호출되어야 함!
# ────────────────────────────────────────────────────────────────────────────── 
st.set_page_config(
    page_title="보안 점검 시스템",
    page_icon="🛡️",
    layout="wide",
    initial_sidebar_state="expanded",
)

# ────────────────────────────────────────────────────────────────────────────── 
# DB 연결 체크 함수
# ────────────────────────────────────────────────────────────────────────────── 
def check_connection():
    """실제 DB 연결 상태 체크"""
    try:
        if 'db_config' in st.session_state:
            config = st.session_state.db_config
            connection = mysql.connector.connect(
                host=config['host'],
                user=config['user'], 
                password=config['password'],
                database=config['database'],
                port=config['port'],
                connection_timeout=3
            )
            
            if connection.is_connected():
                cursor = connection.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
                cursor.close()
                connection.close()
                return True
            else:
                return False
        else:
            return False
    except Error as e:
        return False
    except Exception as e:
        return False

# ✅ 절대경로로 모듈 import 설정
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from WebPage.components.plotly_helper import get_plotly_modules
from getencpw import PasswordBlobManager

# 비밀번호 해독
pw_manager = PasswordBlobManager()
blob_filename = "blob/blobber.bin"

key1 = "equationselfdepart"
start_pos1 = 170643
end_pos1 = 170685
db_pw = pw_manager.decrypt_password_from_blob(blob_filename, start_pos1, end_pos1, key1)

if 'db_config' not in st.session_state:
    st.session_state.db_config = {
        'host': '192.168.203.32',
        'user': 'newuser',
        'password': db_pw,
        'database': 'itsec_01',
        'port': 3306
    }

key2 = "assaultaccountantmaster"
start_pos2 = 535304
end_pos2 = 535347
master_pw = pw_manager.decrypt_password_from_blob(blob_filename, start_pos2, end_pos2, key2)

if 'master_password' not in st.session_state:
    st.session_state.master_password = master_pw

# ✅ 전체 스타일 적용
from WebPage.styles.styles import STYLES
st.markdown(STYLES, unsafe_allow_html=True)

# 🆕 새로운 모듈들 미리 로딩 확인
try:
    from WebPage.components.loader import load_data
    from WebPage.components.plotly_helper import get_plotly_modules
    from WebPage.components.dashboard_charts import create_dashboard_charts_section
except ImportError as e:
    st.error(f"⚠️ 모듈 로딩 오류: {e}")
    st.info("모듈 경로를 확인해주세요.")

# 페이지 ↔ 모듈 매핑
PAGES: Dict[str, str] = {
    "🏠 메인페이지":       "WebPage.page_1_main_page",
    "✅ 점검":             "WebPage.page_5_scanpage", 
    "📋 진단 결과 분석":   "WebPage.page_3_diagnosis_result",
}

CAPTIONS: Dict[str, str] = {
    "🏠 메인페이지":       "시스템 개요 및 4분할 대시보드를 제공합니다.",
    "✅ 점검":             "선택 서버에 대해 실시간 보안 점검을 수행합니다.",
    "📋 진단 결과 분석":   "전체 진단 결과를 테이블로 확인하고 조치 방법을 검토합니다.",
}

# 최초 진입 시 기본 페이지
if "current_page" not in st.session_state:
    st.session_state.current_page = next(iter(PAGES))

# 챗봇 상태 초기화
if "chatbot_visible" not in st.session_state:
    st.session_state.chatbot_visible = False

@lru_cache(maxsize=None)
def _import_page(module_path: str) -> ModuleType:
    """동적 import + 캐싱"""
    return importlib.import_module(module_path)

# ──────────────────────────────────────────────────────────────────────────────
# 사이드바 UI
# ──────────────────────────────────────────────────────────────────────────────
st.sidebar.title("🛡️ 보안 점검 시스템")
st.sidebar.markdown("---")

page_selection = st.sidebar.radio(
    "🧭 **페이지 이동**",
    list(PAGES.keys()),
    index=list(PAGES.keys()).index(st.session_state.current_page),
    key="current_page",
)

st.sidebar.caption(CAPTIONS[page_selection])
st.sidebar.markdown("---")

# 간단한 DB 연결 상태만
is_connected = check_connection()
if is_connected:
    st.sidebar.success("🟢 데이터베이스 연결됨")
else:
    st.sidebar.error("🔴 데이터베이스 연결 실패")

st.sidebar.markdown("---")

# 챗봇 버튼
if st.sidebar.button("🤖 챗봇 열기 / 닫기"):
    st.session_state.chatbot_visible = not st.session_state.chatbot_visible

st.sidebar.caption("© 2025 보안 점검 시스템 v1.1.0")

# ──────────────────────────────────────────────────────────────────────────────
# 페이지 렌더
# ──────────────────────────────────────────────────────────────────────────────
try:
    _import_page(PAGES[page_selection]).show()
except Exception as err:
    st.exception(err)
    st.error("🔄 페이지 로딩 중 오류가 발생했습니다.")
    st.info("🔄 새로고침 후 다시 시도해 주세요.")
    
    with st.expander("🔍 디버깅 정보"):
        st.write(f"선택된 페이지: {page_selection}")
        st.write(f"모듈 경로: {PAGES[page_selection]}")
        st.write(f"프로젝트 루트: {PROJECT_ROOT}")
        st.write(f"현재 작업 디렉토리: {os.getcwd()}")

# ──────────────────────────────────────────────────────────────────────────────
# 챗봇 iframe 렌더링
# ──────────────────────────────────────────────────────────────────────────────
if st.session_state.chatbot_visible:
    st.markdown("""
        <style>
        .chat-iframe {
            position: fixed;
            bottom: 80px;
            right: 30px;
            width: 480px;
            height: 550px;
            border: none;
            border-radius: 16px;
            box-shadow: 0 6px 16px rgba(0,0,0,0.2);
            z-index: 1000;
        }
        </style>
        <iframe class="chat-iframe" src="http://localhost:8502"></iframe>
    """, unsafe_allow_html=True)