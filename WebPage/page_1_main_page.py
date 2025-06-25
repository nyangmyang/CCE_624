"""page_1_main_page.py – Security KPI Dashboard (4분할 차트 추가 버전)

* 2025‑06‑21 • 4분할 차트 섹션 추가
* 2025‑06‑24 • DB 연동 추가

* 추가된 기능:
    - 📊 호스트별 보안 수준 막대 차트
    - 📈 영역별 취약점 현황 도넛 차트  
    - 📉 중요도별 취약점 분포 스택 바 차트
    - 🎯 시간별 보안 개선 추이 라인 차트
    - 🔄 DB 실시간 연동 (JSON 폴백)
"""

from __future__ import annotations

from datetime import datetime
from functools import lru_cache
from typing import List, Dict

import pandas as pd
import streamlit as st

# ✅ 절대경로로 모듈 import 설정
import sys
import os

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, '..'))

# 루트 강제로 sys.path에 추가
if PROJECT_ROOT not in sys.path:
    sys.path.append(PROJECT_ROOT)

# 이제 절대경로 import (DB 함수 추가)
from WebPage.components.loader import load_data, load_test_result
from WebPage.components.filters import create_sidebar_filters, apply_filters, show_filter_summary

from WebPage.components.plotly_helper import (
    create_vulnerability_gauge,
    create_trend_chart
)
# 🆕 새로운 4분할 대시보드 차트 모듈
from WebPage.components.dashboard_charts import create_dashboard_charts_section
from WebPage.styles.styles import STYLES
from WebPage.styles.pretty import (
    MAIN_PAGE_CSS, 
    COLORS, 
    RISK_COLORS, 
    GAUGE_COLORS,
    GAUGE_COLORS_RGBA,
    get_risk_color_and_icon,
    kpi_card_style,
    server_card_style
)

# ──────────────────────────────────────────────────────────────────────────────
# 1) KPI 계산 (순수 계산 로직만)
# ──────────────────────────────────────────────────────────────────────────────
def calc_kpi(df: pd.DataFrame) -> dict:
    """
    보안 KPI 지표 계산
    
    Args:
        df: loader.py에서 전처리된 DataFrame
        
    Returns:
        dict: KPI 지표들 (전체, 양호율, 취약률, 고위험, 점수)
    """
    total = len(df)
    if not total:
        return dict.fromkeys(
            ["total", "good_ratio", "vuln_ratio", "high_risk", "score"], 0
        )

    good = (df["확인결과"] == "양호").sum()
    vuln = (df["확인결과"] == "취약").sum()
    high = ((df["위험도"] == "높음") & (df["확인결과"] == "취약")).sum()

    good_ratio = round(good / total * 100, 1)
    vuln_ratio = round(vuln / total * 100, 1)
    penalty = high / total * 20
    score = round(max(0, good_ratio - penalty), 1)

    return {
        "total": total,
        "good_ratio": good_ratio,
        "vuln_ratio": vuln_ratio,
        "high_risk": high,
        "score": score,
    }

# ──────────────────────────────────────────────────────────────────────────────
# 🆕 DB 데이터 처리 함수 (KPI 계산 바로 아래에 추가!)
# ──────────────────────────────────────────────────────────────────────────────
def process_db_data(raw_data):
    """
    DB에서 가져온 raw 데이터를 기존 DataFrame 형태로 변환
    
    Args:
        raw_data: load_test_result()에서 반환된 데이터
        
    Returns:
        pd.DataFrame: 기존 load_data()와 동일한 형태의 DataFrame
    """
    # 매핑 테이블 (loader.py와 동일)
    RESULT_MAP = {
        0: "양호",
        1: "취약", 
        2: "해당없음"
    }
    
    IMPORTANCE_MAP = {
        1: "낮음",
        2: "보통",
        3: "높음"
    }
    
    processed_data = []
    
    try:
        for record in raw_data:
            # DB 레코드를 DataFrame 형태로 변환
            processed_record = {
                'PC명': record.get('hostname', record.get('pc_name', 'Unknown')),
                '확인결과': RESULT_MAP.get(record.get('result', 2), '해당없음'),
                '위험도': IMPORTANCE_MAP.get(record.get('importance', 1), '낮음'),
                '점검항목': record.get('check_item', record.get('title', '')),
                '카테고리': record.get('category', '기타'),
                '점검일시': record.get('check_date', datetime.now().strftime('%Y-%m-%d %H:%M:%S')),
                # 🆕 중요: plotly_helper.py에서 필요한 컬럼들 추가!
                '진단시점': record.get('check_date', datetime.now().strftime('%Y-%m-%d %H:%M:%S')),  # 차트용
                '진단일자': record.get('check_date', datetime.now().strftime('%Y-%m-%d')),         # 날짜만
                '서버명': record.get('hostname', record.get('pc_name', 'Unknown')),                 # 서버명 별칭
            }
            processed_data.append(processed_record)
            
        return pd.DataFrame(processed_data)
        
    except Exception as e:
        st.error(f"❌ 데이터 변환 중 오류: {e}")
        return pd.DataFrame()

# ──────────────────────────────────────────────────────────────────────────────
# 2) UI 컴포넌트들 (CSS 모듈화 적용)
# ──────────────────────────────────────────────────────────────────────────────

def kpi_card(label: str, value, unit: str, color: str):
    """KPI 카드 컴포넌트 (styles 모듈의 헬퍼 함수 사용)"""
    st.markdown(
        f"""
        <div style='{kpi_card_style(color)}'>
            <h4 style='margin:0;font-size:14px;color:#333'>{label}</h4>
            <h1 style='margin:8px 0;font-size:32px;color:{color};font-weight:700'>{value}</h1>
            <p style='margin:0;font-size:12px;color:#666'>{unit}</p>
        </div>
        """,
        unsafe_allow_html=True,
    )

def _top_vulnerable(df: pd.DataFrame) -> None:
    """PC 별 취약건수 Top 5 테이블."""
    vuln = df[df["확인결과"] == "취약"]
    if vuln.empty:
        st.success("🎉 취약한 항목이 없습니다!")
        return
    tbl = (
        vuln.groupby("PC명").size()
        .sort_values(ascending=False)
        .head(5)
        .reset_index(name="취약건수")
    )
    st.table(tbl)

# ──────────────────────────────────────────────────────────────────────────────
# 3) 취약점 대시보드 함수들 (plotly_helper 모듈 적용)
# ──────────────────────────────────────────────────────────────────────────────
def create_server_list(df: pd.DataFrame) -> None:
    """📌 취약 장비 순위 - Streamlit container height 사용하여 스크롤 구현"""

    # 1️⃣ 서버별 취약률 계산
    server_stats = []
    for pc_name in df["PC명"].unique():
        server_data = df[df["PC명"] == pc_name]
        total = len(server_data)
        vuln_count = (server_data["확인결과"] == "취약").sum()
        vuln_ratio = (vuln_count / total * 100) if total > 0 else 0

        server_stats.append({
            'server': pc_name,
            'vuln_ratio': vuln_ratio,
            'vuln_count': vuln_count,
            'total': total
        })

    # 취약률 순 정렬
    server_stats.sort(key=lambda x: x['vuln_ratio'], reverse=True)

    # 2️⃣ 헤더 (고정)
    st.markdown(f"""
    <div style="
        border:1px solid #e5e7eb; 
        border-radius:12px; 
        padding:16px; 
        background:#fff;
        margin-bottom: 16px;
    ">
        <h3 style="margin:0; font-size:18px; color:#1e40af; display:flex; align-items:center; gap:8px">
          🚨 취약 장비 순위
          <span style="background:#3b82f6; color:white; padding:2px 8px; border-radius:8px; font-size:12px">
            {len(server_stats)}대
          </span>
        </h3>
    </div>
    """, unsafe_allow_html=True)

    # 3️⃣ 스크롤 가능한 카드 영역 - 여기가 핵심!
    with st.container(height=350):
        if server_stats:
            for i, server in enumerate(server_stats):
                color, icon = get_risk_color_and_icon(server['vuln_ratio'])
                rank_icon = "🥇" if i == 0 else "🥈" if i == 1 else "🥉" if i == 2 else f"{i+1}위"

                st.markdown(f"""
                <div style='
                    border-left: 4px solid {color}; 
                    margin-bottom: 8px;
                    background: white;
                    border-radius: 12px;
                    padding: 16px;
                    border: 1px solid #e5e7eb;
                    box-shadow: 0 2px 8px -2px rgba(0, 0, 0, 0.08);
                '>
                    <div style='display:flex; align-items:center; gap:12px'>
                        <div style='font-size:16px; min-width:40px; text-align:center; font-weight:bold'>
                            {rank_icon}
                        </div>
                        <div style='font-size:18px'>{icon}</div>
                        <div style='flex:1'>
                            <div style='font-weight:bold; font-size:14px; color:#333; margin-bottom:2px'>
                                {server['server']}
                            </div>
                            <div style='font-size:12px; color:#666'>
                                {server['vuln_count']}/{server['total']} 취약점 발견
                            </div>
                        </div>
                        <div style='font-weight:bold; font-size:16px; color:{color}; text-align:right'>
                            {server['vuln_ratio']:.1f}%
                        </div>
                    </div>
                </div>
                """, unsafe_allow_html=True)
        else:
            st.markdown("<p style='color:#888'>⚠️ 표시할 장비가 없습니다.</p>", unsafe_allow_html=True)

    # 4️⃣ 평균 요약 (박스 밖)
    if server_stats:
        avg_vuln = sum(s['vuln_ratio'] for s in server_stats) / len(server_stats)
        st.markdown(f"""
        <div style='margin-top:12px; padding:8px 12px; background:rgba(59,130,246,0.1); 
                    border-radius:8px; text-align:center; font-size:13px'>
            📊 평균 취약률: <strong>{avg_vuln:.1f}%</strong>
        </div>
        """, unsafe_allow_html=True)

# ──────────────────────────────────────────────────────────────────────────────
# 4) Main 엔트리 – Streamlit 페이지
# ──────────────────────────────────────────────────────────────────────────────

def show():
    """app.py 라우팅에서 호출되는 메인 함수."""
    # ✅ CSS 적용 - styles 모듈에서 import
    st.markdown(MAIN_PAGE_CSS, unsafe_allow_html=True)
    
    # 🆕 개발 모드 체크박스 추가 (사이드바에)
    st.sidebar.markdown("---")
    dev_mode = st.sidebar.checkbox("🛠️ 개발 모드 (JSON 파일)", value=True)
    if dev_mode:
        st.sidebar.caption("📁 JSON 파일 사용 중")
    else:
        st.sidebar.caption("🔗 실제 DB 연결 중")
    st.sidebar.markdown("---")
    
    # 1. 데이터 로딩 (개발 모드에 따라 분기)
    if dev_mode:
        # 🎯 JSON 파일에서 직접 로딩
        st.info("🛠️ 개발 모드: JSON 파일에서 데이터를 읽습니다")
        try:
            df = load_data()  # 기존 JSON 로더 사용
            st.success("✅ JSON 파일 로딩 성공!")
        except Exception as e:
            st.error(f"❌ JSON 파일 읽기 실패: {str(e)}")
            return
    else:
        # 실제 DB 데이터 로딩 (기존 로직)
        try:
            st.info("🔄 데이터베이스에서 최신 데이터를 가져오는 중...")
            raw_data = load_test_result()
            df = process_db_data(raw_data)
            st.success("✅ 데이터베이스 연결 성공!")
        except Exception as e:
            st.warning(f"⚠️ DB 연결 실패: {str(e)}")
            st.info("📁 JSON 파일에서 데이터를 읽어옵니다...")
            try:
                df = load_data()
                st.success("✅ JSON 파일 로딩 성공!")
            except Exception as e2:
                st.error(f"❌ JSON 파일도 읽을 수 없습니다: {str(e2)}")
                return
    
    if df.empty:
        st.error("📊 표시할 데이터가 없습니다.")
        return
    
    # 2. 사이드바 필터 생성
    filters = create_sidebar_filters(df)
    
    # 3. 필터 적용  
    filtered_df = apply_filters(df, filters)
    
    # 4. KPI 계산 
    metrics = calc_kpi(filtered_df)

    st.markdown("---")

    # ── 상단 배너 ---------------------------------------------------------------
    st.markdown('<div class="section-container">', unsafe_allow_html=True)
    st.markdown(f"# **⚠️전체 취약점 현황**")
    col_gauge, col_stats = st.columns([2, 4])

    with col_gauge:
        st.markdown("### 🎯평균 취약도 수준")
        # ✅ plotly_helper 모듈의 함수 사용
        gauge_chart = create_vulnerability_gauge(metrics['vuln_ratio'], metrics['total'])
        st.plotly_chart(gauge_chart, use_container_width=True)

    with col_stats:
        st.markdown("#### 🗂️주요 지표")
        for lbl, cnt in {
            "취약 서버 수": metrics['total'] - (filtered_df["확인결과"] == "양호").sum(),
            "위험": metrics['high_risk'],
            "안전": (filtered_df["확인결과"] == "양호").sum(),
        }.items():
            pct = cnt / metrics['total'] * 100 if metrics['total'] else 0
            st.progress(pct / 100, text=f"{lbl}: {cnt} devices ({pct:.1f}%)")
    
    # ✅ 첫 번째 컨테이너 닫기
    st.markdown('</div>', unsafe_allow_html=True)

    # ── 취약점 대시보드 섹션 
    st.markdown("---")
    st.markdown('<div class="section-container">', unsafe_allow_html=True)
    st.markdown("## 🔍 상세 취약점 분석")
        
    # 2열 레이아웃: 왼쪽(서버 리스트) + 오른쪽(트렌드 차트)
    col_servers, col_trend = st.columns([1, 2])
    
    with col_servers:
        create_server_list(filtered_df)
    
    with col_trend:
        # ✅ plotly_helper 모듈의 함수 사용
        trend_fig = create_trend_chart(filtered_df)  
        st.plotly_chart(trend_fig, use_container_width=True)
    
    # ✅ 두 번째 컨테이너 닫기
    st.markdown('</div>', unsafe_allow_html=True)

    # 🆕 ── 4분할 차트 섹션 (dashboard_charts 모듈 사용) - 여기로 이동! -------
    st.markdown('<div class="section-container">', unsafe_allow_html=True)
    create_dashboard_charts_section(filtered_df)
    st.markdown('</div>', unsafe_allow_html=True)

    # ── 서버별 상세 현황
    if st.checkbox("🔍 서버별 상세 현황 보기"):
        st.markdown('<div class="section-container">', unsafe_allow_html=True)
        st.markdown("### 📊 서버별 상세 현황")
        
        # 서버별 상세 데이터 계산
        server_details = []
        for pc_name in filtered_df["PC명"].unique():
            pc_data = filtered_df[filtered_df["PC명"] == pc_name]
            total = len(pc_data)
            vuln_count = (pc_data["확인결과"] == "취약").sum()
            good_count = (pc_data["확인결과"] == "양호").sum()
            
            server_details.append({
                'PC명': pc_name,
                '총 항목': total,
                '취약 항목': vuln_count,
                '양호 항목': good_count,
                '취약률(%)': round(vuln_count / total * 100, 1) if total > 0 else 0,
                '양호율(%)': round(good_count / total * 100, 1) if total > 0 else 0
            })
        
        if server_details:
            server_df = pd.DataFrame(server_details)
            server_df = server_df.sort_values('취약률(%)', ascending=False)
            
            st.dataframe(
                server_df,
                use_container_width=True,
                hide_index=True
            )
        else:
            st.info("표시할 서버 데이터가 없습니다.")
        
        # ✅ 마지막 컨테이너 닫기
        st.markdown('</div>', unsafe_allow_html=True)