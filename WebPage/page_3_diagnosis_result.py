from __future__ import annotations

import json, os
from datetime import datetime
from functools import lru_cache
from pathlib import Path
from typing import Dict, List

import pandas as pd
import streamlit as st
from st_aggrid import AgGrid, GridOptionsBuilder

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from WebPage.styles.page_3_style import PAGE3_STYLE
from db_test import TestManager

BASE_DIR = Path(__file__).resolve().parent

@st.cache_resource(show_spinner=False)
def _lazy_parsing_proc():
    from Parsing.parsingMain import process_json_files
    return process_json_files

@st.cache_data(show_spinner=False)
def _load_df(result_dir: str) -> pd.DataFrame:
    # Replace to streamlit.session_state
    db_config = {
        'host': 'localhost',
        'user': 'nyangnyang',
        'password': '0000',
        'database': 'itsec_01'
    }

    test_manager = TestManager(db_config)

    rows: List[Dict] = []
    for fname in os.listdir(result_dir):
        if not fname.endswith(".json"):
            continue
        with open(os.path.join(result_dir, fname), encoding="utf-8") as fp:
            # Adds result to db
            test_manager.create_test(1, int(fname.rsplit('.', 1)[0]), fp.read(), datetime.now())
            fp.seek(0)
            js = json.load(fp)
        rows.extend(_parse_json(js, fname))

    test_manager.conn.commit()
    test_manager.conn.close()
    # Remove completed files
    #for fname in os.listdir(result_dir):
       #if fname.endswith('.json'):
        #   os.remove(os.path.join(result_dir, fname))
    return pd.DataFrame(rows)

def _parse_json(js: Dict, fname: str) -> List[Dict]:
    imp = {1: "하", 2: "중", 3: "상"}.get
    res  = {0: "양호", 1: "취약", 2: "인터뷰"}.get 
    rows = []
    for it in js.get("result", []):
        rows.append(
            {
                "진단코드":  it.get("itemcode", "N/A"),
                "중요도":    imp(it.get("importance", 0)),
                "진단항목":  it.get("title", "N/A"),
                "결과":      res(it.get("result", 0)),
                "조치방법":  it.get("resultdetail", "N/A"),
                "호스트":     Path(fname).stem,
                "진단시점":  js.get("testedtime", "Unknown"),
                "OS정보":    js.get("osinfo", "Unknown"),
            }
        )
    return rows

@lru_cache(maxsize=None)
def _kpi(_: int, total: int, vuln: int, good: int, high: int):
    g_ratio = round(good / total * 100, 1) if total else 0.0
    v_ratio = round(vuln / total * 100, 1) if total else 0.0
    score   = round(max(0, g_ratio - (high / total * 20) if total else 0), 1)
    return g_ratio, v_ratio, score

def _header():
    st.markdown(PAGE3_STYLE, unsafe_allow_html=True)
    st.markdown(
        '<div class="page-title"><h1>진단 결과 페이지</h1></div>',
        unsafe_allow_html=True,
    )
def _filter_box(df: pd.DataFrame) -> pd.DataFrame:
    if "reset_filters" not in st.session_state:
        st.session_state.reset_filters = False

    if st.session_state.reset_filters:
        # 모든 필터 초기화
        for key in ['selected_hostnames', 'selected_ips', 'selected_os', 'selected_importance', 
                   'selected_results', 'selected_categories', 'item_search']:
            if key in st.session_state:
                del st.session_state[key]
        st.session_state.reset_filters = False

    # 스타일 추가
    st.markdown("""
    <style>
    .filter-section {
        background-color: white;
        padding: 1rem;
        border-radius: 0.5rem;
        border: 1px solid #e5e7eb;
        margin-bottom: 1rem;
    }
    .filter-header {
        font-size: 1.1rem;
        font-weight: 600;
        color: #374151;
        margin-bottom: 0.5rem;
    }
    .reset-btn {
        background-color: #f3f4f6 !important;
        color: #374151 !important;
        border: 1px solid #d1d5db !important;
    }
    </style>
    """, unsafe_allow_html=True)

    # 헤더와 초기화 버튼
    col_header, col_reset = st.columns([4, 1])
    with col_header:
        st.markdown("### 🔍 보안 점검 필터")
        st.caption("취약점 점검 결과를 다양한 기준으로 필터링할 수 있습니다.")
    
    with col_reset:
        if st.button("🔄 필터 초기화", key="reset_btn", help="모든 필터를 초기화합니다"):
            st.session_state.reset_filters = True
            st.rerun()

    # 📌 통합 필터 익스펜더
    with st.expander(" ",expanded=True):
        # 1️⃣ PC / 자산 기준
        st.markdown("#### 🖥️ PC / 자산 기준")
        col1, col2, col3 = st.columns(3)
        
        with col1:
            #st.markdown("**Hostname**")
            hostname_options = sorted([x for x in df["호스트"].unique() if x is not None])
            selected_hostnames = st.multiselect(
                "**PC 이름 선택**",
                options=hostname_options,
                default=st.session_state.get('selected_hostnames', []),
                key='selected_hostnames',
                placeholder="PC 이름을 선택하세요..."
            )
        
        with col2:
            st.markdown("**IP 주소**")
            # IP 주소는 OS정보에서 추출하거나 별도 컬럼이 있다면 사용
            ip_options = []
            if "IP주소" in df.columns:
                ip_options = sorted([x for x in df["IP주소"].unique() if x is not None])
            else:
                # OS정보에서 IP 추출 시도
                for os_info in df["OS정보"].unique():
                    if pd.notna(os_info) and "IP" in str(os_info):
                        ip_options.append(str(os_info))
                ip_options = sorted(list(set(ip_options)))
            
            selected_ips = st.multiselect(
                "IP 주소 선택", 
                options=ip_options,
                default=st.session_state.get('selected_ips', []),
                key='selected_ips',
                placeholder="IP 주소를 선택하세요..."
            )
        
        with col3:
            st.markdown("**OS 유형**")
            os_options = sorted([x for x in df["OS정보"].unique() if x is not None])
            selected_os = st.multiselect(
                "OS 유형 선택",
                options=os_options,
                default=st.session_state.get('selected_os', []),
                key='selected_os',
                placeholder="OS를 선택하세요..."
            )

        st.divider()  # 구분선

        # 2️⃣ 중요도 / 위험도 기준  
        st.markdown("#### ⚠️ 중요도 / 위험도 기준")
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("**중요도**")
            importance_options = sorted([x for x in df["중요도"].unique() if x is not None])
            selected_importance = st.multiselect(
                "중요도 선택",
                options=importance_options,
                default=st.session_state.get('selected_importance', []),
                key='selected_importance',
                placeholder="중요도를 선택하세요..."
            )
        
        with col2:
            st.markdown("**우선 조치 여부**")
            priority_options = ["즉시조치 필요", "모니터링 가능"]
            selected_priority = st.multiselect(
                "우선 조치 선택",
                options=priority_options,
                default=[],
                placeholder="조치 우선순위를 선택하세요..."
            )

        st.divider()  # 구분선

        # 3️⃣ 점검 항목 기준
        st.markdown("#### 📋 점검 항목 기준")
        col1, col2 = st.columns([2, 1])
        
        with col1:
            st.markdown("**취약점 카테고리**")
            # title 기반으로 세부 카테고리 분류
            def categorize_by_title(title):
                if pd.isna(title):
                    return "기타"
                
                title_lower = str(title).lower()
                
                if any(keyword in title_lower for keyword in ["root", "계정", "사용자", "user", "account"]):
                    return "계정 관리"
                elif any(keyword in title_lower for keyword in ["패스워드", "password", "비밀번호"]):
                    return "패스워드 정책"
                elif any(keyword in title_lower for keyword in ["파일", "권한", "file", "permission"]):
                    return "파일 권한"
                elif any(keyword in title_lower for keyword in ["네트워크", "network", "ssh", "ftp", "telnet"]):
                    return "네트워크 설정"
                elif any(keyword in title_lower for keyword in ["서비스", "service", "데몬", "daemon"]):
                    return "서비스 관리"
                elif any(keyword in title_lower for keyword in ["로그", "log", "감사", "audit"]):
                    return "로그 관리"
                elif any(keyword in title_lower for keyword in ["시스템", "system", "커널", "kernel"]):
                    return "시스템 설정"
                else:
                    return "기타"
            
            # 카테고리 생성
            df_with_category = df.copy()
            df_with_category['카테고리'] = df_with_category['진단항목'].apply(categorize_by_title)
            
            category_options = sorted(df_with_category['카테고리'].unique())
            
            selected_categories = st.multiselect(
                "카테고리 선택",
                options=category_options,
                default=st.session_state.get('selected_categories', []),
                key='selected_categories',
                placeholder="취약점 카테고리를 선택하세요..."
            )
        
        with col2:
            st.markdown("**항목 검색**")
            item_search = st.text_input(
                "코드/제목 검색",
                value=st.session_state.get('item_search', ''),
                key='item_search',
                placeholder="예: U-01, root 접속"
            )

        st.divider()  # 구분선

        # 4️⃣ 상태 기준
        st.markdown("#### ✅ 상태 기준")
        col1, col2 = st.columns([2, 1])
        with col1:
            st.markdown("**점검 결과**")
            result_options = sorted([x for x in df["결과"].unique() if x is not None])
            selected_results = st.multiselect(
                "결과 선택",
                options=result_options,
                default=st.session_state.get('selected_results', ["취약"]),  # 기본값: 취약만
                key='selected_results',
                placeholder="점검 결과를 선택하세요..."
            )
        
        with col2:
            st.info("💡 **기본 뷰**: 취약 항목만 표시됩니다.")

    # 기본 정렬 설정
    st.markdown("---")  # 구분선
    col_sort1, col_sort2 = st.columns(2)
    with col_sort1:
        s_col = st.selectbox("정렬 기준", ["진단코드","중요도","진단항목","결과"], 
                           index=0, key="sort_col")
    with col_sort2:
        s_ord = st.selectbox("정렬 순서", ["오름차순","내림차순"], 
                           index=0, key="sort_order")

    # ========== 필터 적용 로직 ==========
    out = df.copy()
    
    # PC/자산 기준 필터
    if selected_hostnames:
        out = out[out["호스트"].isin(selected_hostnames)]
    
    if selected_ips:
        # IP 필터링 로직 (OS정보에 IP가 포함된 경우)
        ip_mask = out["OS정보"].astype(str).str.contains('|'.join(selected_ips), case=False, na=False)
        out = out[ip_mask]
    
    if selected_os:
        out = out[out["OS정보"].isin(selected_os)]
    
    # 중요도 필터
    if selected_importance:
        out = out[out["중요도"].isin(selected_importance)]
    
    # 상태 필터
    if selected_results:
        out = out[out["결과"].isin(selected_results)]
    
    # 카테고리 필터
    if selected_categories:
        # title 기반 카테고리 필터링
        def categorize_by_title(title):
            if pd.isna(title):
                return "기타"
            
            title_lower = str(title).lower()
            
            if any(keyword in title_lower for keyword in ["root", "계정", "사용자", "user", "account"]):
                return "계정 관리"
            elif any(keyword in title_lower for keyword in ["패스워드", "password", "비밀번호"]):
                return "패스워드 정책"
            elif any(keyword in title_lower for keyword in ["파일", "권한", "file", "permission"]):
                return "파일 권한"
            elif any(keyword in title_lower for keyword in ["네트워크", "network", "ssh", "ftp", "telnet"]):
                return "네트워크 설정"
            elif any(keyword in title_lower for keyword in ["서비스", "service", "데몬", "daemon"]):
                return "서비스 관리"
            elif any(keyword in title_lower for keyword in ["로그", "log", "감사", "audit"]):
                return "로그 관리"
            elif any(keyword in title_lower for keyword in ["시스템", "system", "커널", "kernel"]):
                return "시스템 설정"
            else:
                return "기타"
        
        out['카테고리'] = out['진단항목'].apply(categorize_by_title)
        out = out[out['카테고리'].isin(selected_categories)]
    
    # 항목 검색
    if item_search:
        search_mask = (
            out["진단코드"].astype(str).str.contains(item_search, case=False, na=False) |
            out["진단항목"].astype(str).str.contains(item_search, case=False, na=False)
        )
        out = out[search_mask]
    
    # 정렬
    out = out.sort_values(s_col, ascending=(s_ord == "오름차순"))
    
    # 적용된 필터 요약 표시
    if len(out) != len(df):
        st.success(f"🎯 필터 적용 완료: {len(df)}개 중 {len(out)}개 항목이 선택되었습니다.")
    
    return out.reset_index(drop=True)

def _actions(df: pd.DataFrame):
    st.markdown('<div class="actions-section">', unsafe_allow_html=True)
    col_xls = st.columns(1)[0]
    if col_xls.button("상세 Excel 보고서 내보내기", use_container_width=True):
        st.info("보고서 생성 중…")
        try:
            _lazy_parsing_proc()()
            st.success("완료!")
        except Exception as e:
            st.error(f"오류: {e}")
    st.markdown("</div>", unsafe_allow_html=True)

def show():
    st.markdown(PAGE3_STYLE, unsafe_allow_html=True)
    base = Path(__file__).resolve().parent.parent  # WebPage의 상위 디렉토리 (CCE_624)
    tmp_dir = base / "tmp"  # D:\CCE_624\tmp
    
    df = _load_df(str(tmp_dir))

    if df.empty:
        st.warning("데이터가 없습니다.")
        return

    _header()
    st.markdown("<div style='height: 2.2rem'></div>", unsafe_allow_html=True)

    filtered_df = _filter_box(df)

    
    st.markdown("<div style='height: 2.2rem'></div>", unsafe_allow_html=True)
    kpi_cols = st.columns(4)
    kpi_vals = [
        ("총 항목", len(filtered_df), "#6366f1"),
        ("양호",   (filtered_df["결과"] == "양호").sum(), "#22c55e"),
        ("취약",   (filtered_df["결과"] == "취약").sum(), "#ef4444"),
        ("인터뷰",   (filtered_df["결과"] == "인터뷰").sum(), "#f59e42"),
        # ("고위험", (filtered_df["위험도"] == "높음").sum(), "#f59e42"),
    ]
    for col, (label, value, color) in zip(kpi_cols, kpi_vals):
        col.markdown(f"""
        <div class='kpi-card'>
            <div class='kpi-label' style='color:{color};'>{label}</div>
            <div class='kpi-value' style='color:{color};'>{value}</div>
        </div>
        """, unsafe_allow_html=True)

    

if __name__ == "__main__":
    st.set_page_config(page_title="진단 결과", layout="wide")
    show()
