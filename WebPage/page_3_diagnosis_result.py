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
        'host': '192.168.203.32',
        'user': 'newuser',
        'password': 'easypw12',
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
    
    # 제목과 초기화 버튼을 같은 라인에 배치
    col_title, col_reset = st.columns([5, 1])
    
    with col_title:
        st.markdown(
            '<div class="page-title"><h1>🐰진단 결과 페이지</h1></div>',
            unsafe_allow_html=True,
        )
    
    with col_reset:
        st.markdown("") 
        st.markdown("")  # 버튼 위치를 더 아래로
        if st.button("🔄초기화", key="reset_btn", help="모든 필터를 초기화합니다"):
            st.session_state.reset_filters = True
            st.rerun()

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

    # 📌 통합 필터 익스펜더
    with st.expander(" ",expanded=True):
        # 1️⃣ PC / 자산 기준
        st.markdown("#### 🖥️ PC / 자산 기준")
        col1, col2, col3 = st.columns(3)
        
        with col1:
            hostname_options = sorted([x for x in df["호스트"].unique() if x is not None])
            selected_hostnames = st.multiselect(
                "**PC 이름 선택**",
                options=hostname_options,
                default=st.session_state.get('selected_hostnames', []),
                key='selected_hostnames',
                placeholder="PC 이름을 선택하세요..."
            )
        
        with col2:
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
                "**IP 주소 선택**", 
                options=ip_options,
                default=st.session_state.get('selected_ips', []),
                key='selected_ips',
                placeholder="IP 주소를 선택하세요..."
            )
        
        with col3:
            os_options = sorted([x for x in df["OS정보"].unique() if x is not None])
            selected_os = st.multiselect(
                "**OS 유형 선택**",
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
            importance_options = sorted([x for x in df["중요도"].unique() if x is not None])
            selected_importance = st.multiselect(
                "**중요도 선택**",
                options=importance_options,
                default=st.session_state.get('selected_importance', []),
                key='selected_importance',
                placeholder="중요도를 선택하세요..."
            )
        
        with col2:
            priority_options = ["즉시조치 필요", "모니터링 가능"]
            selected_priority = st.multiselect(
                "**우선 조치 선택**",
                options=priority_options,
                default=[],
                placeholder="조치 우선순위를 선택하세요..."
            )

        st.divider()  # 구분선

        # 3️⃣ 점검 항목 기준
        st.markdown("#### 📋 점검 항목 기준")
        col1, col2 = st.columns([2, 1])
        
        with col1:
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
                "**카테고리 선택**",
                options=category_options,
                default=st.session_state.get('selected_categories', []),
                key='selected_categories',
                placeholder="취약점 카테고리를 선택하세요..."
            )
        
        with col2:
            item_search = st.text_input(
                "**코드/제목 검색**",
                value=st.session_state.get('item_search', ''),
                key='item_search',
                placeholder="예: U-01, root 접속"
            )

        st.divider()  # 구분선

        # 4️⃣ 상태 기준
        st.markdown("#### ✅ 상태 기준")
        col1, col2 = st.columns([2, 1])
        with col1:
            result_options = sorted([x for x in df["결과"].unique() if x is not None])
            selected_results = st.multiselect(
                "**결과 선택**",
                options=result_options,
                default=st.session_state.get('selected_results', ["양호", "취약", "인터뷰"]),  # 기본값: 취약만
                key='selected_results',
                placeholder="점검 결과를 선택하세요..."
            )
        
        with col2:
            st.info("💡 **기본 뷰**: 취약 항목만 표시됩니다.")

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
    
    # 적용된 필터 요약 표시
    if len(out) != len(df):
        st.success(f"🎯 필터 적용 완료: {len(df)}개 중 {len(out)}개 항목이 선택되었습니다.")
    
    return out.reset_index(drop=True)

def _results_section(df: pd.DataFrame):
    if df.empty:
        st.info("조건에 맞는 데이터가 없습니다.")
        st.markdown("</div>", unsafe_allow_html=True); return

    df_grid = df.copy()
    df_grid['조치'] = '조치하기'
    gb = GridOptionsBuilder.from_dataframe(df_grid)
    gb.configure_pagination(paginationAutoPageSize=True)
    gb.configure_default_column(wrapText=True, autoHeight=True)
    gb.configure_selection('single', use_checkbox=False)

    gb.configure_column("진단코드", width=30)
    gb.configure_column("중요도", width=30)
    gb.configure_column("진단항목", width=150)
    gb.configure_column("결과", width=30, cellClassRules={
        "red-cell":   "value == '취약'",
        "green-cell": "value == '양호'",
        "orange-cell":"value == '인터뷰'",
    })
    gb.configure_column("조치방법", width=300, wrapText=True, autoHeight=True)
    gb.configure_column("호스트", width=150)
    gb.configure_column("진단시점", width=150)
    gb.configure_column("OS정보", width=140)
    gb.configure_column("조치", width=100)

    grid_options = gb.build()

    custom_css = {
        ".red-cell":    {"background-color": "#ffebee", "color": "#c62828", "font-weight": "bold"},
        ".green-cell":  {"background-color": "#e8f5e8", "color": "#2e7d32", "font-weight": "bold"},
        ".orange-cell": {"background-color": "#fff3e0", "color": "#ef6c00", "font-weight": "bold"}
    }

    grid_response = AgGrid(
        df_grid,
        gridOptions=grid_options,
        update_mode='MODEL_CHANGED',
        allow_unsafe_jscode=True,
        fit_columns_on_grid_load=True,  # 화면에 맞춰 컬럼 조정
        theme='blue',
        height=420,
        custom_css=custom_css,
        enable_enterprise_modules=False,
    )

    selected = grid_response['selected_rows']
    # 수정된 부분: DataFrame 체크를 명시적으로 처리
    if selected is not None and len(selected) > 0:
        row = selected[0]
        st.success(f"진단코드 {row['진단코드']}가 클릭되어 조치 처리가 가능합니다.")
    
    st.markdown("</div>", unsafe_allow_html=True)
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
    st.markdown("<div style='height: 0.5rem'></div>", unsafe_allow_html=True)

    filtered_df = _filter_box(df)

    st.markdown("<div style='height: 1.5rem'></div>", unsafe_allow_html=True)
    kpi_cols = st.columns(4)
    kpi_vals = [
        ("총 항목", len(filtered_df), "#6366f1"),
        ("양호",   (filtered_df["결과"] == "양호").sum(), "#22c55e"),
        ("취약",   (filtered_df["결과"] == "취약").sum(), "#ef4444"),
        ("인터뷰",   (filtered_df["결과"] == "인터뷰").sum(), "#f59e42"),
    ]
    for col, (label, value, color) in zip(kpi_cols, kpi_vals):
        col.markdown(f"""
        <div class='kpi-card'>
            <div class='kpi-label' style='color:{color};'>{label}</div>
            <div class='kpi-value' style='color:{color};'>{value}</div>
        </div>
        """, unsafe_allow_html=True)

    st.markdown("<div style='height: 1.5rem'></div>", unsafe_allow_html=True)
    _results_section(filtered_df)
    st.markdown("<div style='height: 1.5rem'></div>", unsafe_allow_html=True)
    _actions(filtered_df)

if __name__ == "__main__":
    st.set_page_config(page_title="진단 결과", layout="wide")
    show()