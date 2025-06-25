"""
dashboard_charts.py - 4분할 대시보드 차트 전용 모듈

* 2025-06-21 • 메인페이지 4분할 차트 섹션용
* 기능:
    📊 호스트별 보안 수준 막대 차트
    📈 영역별 취약점 현황 도넛 차트  
    📉 중요도별 취약점 분포 스택 바 차트 (개선됨)
    🎯 시간별 보안 개선 추이 라인 차트
"""

import pandas as pd
import streamlit as st
from typing import Dict, List

# 절대경로로 모듈 import 설정
import sys
import os
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, "..", ".."))
sys.path.append(PROJECT_ROOT)

# plotly_helper에서 Plotly 모듈 가져오기
from WebPage.components.plotly_helper import get_plotly_modules

# ──────────────────────────────────────────────────────────────────────────────
# 🔧 디버깅 헬퍼 함수
# ──────────────────────────────────────────────────────────────────────────────

def debug_severity_data(df: pd.DataFrame):
    """디버깅용 데이터 확인 함수"""
    print("=" * 50)
    print("🔍 데이터 디버깅 시작")
    print("=" * 50)
    
    print(f"📊 전체 데이터 행 수: {len(df)}")
    print(f"📋 전체 컬럼 수: {len(df.columns)}")
    print(f"📝 컬럼명: {df.columns.tolist()}")
    
    # 위험도 관련 컬럼 찾기
    print("\n🎯 위험도 관련 컬럼 확인:")
    risk_cols = [col for col in df.columns if any(keyword in col.lower() for keyword in ['위험', '중요', 'severity', 'risk', 'priority'])]
    for col in risk_cols:
        print(f"  {col}: {df[col].unique()[:10]}...")  # 처음 10개만 표시
        print(f"    - 데이터 타입: {df[col].dtype}")
        print(f"    - null 값 개수: {df[col].isnull().sum()}")
    
    # 확인결과 관련 컬럼 찾기
    print("\n✅ 확인결과 관련 컬럼 확인:")
    result_cols = [col for col in df.columns if any(keyword in col.lower() for keyword in ['확인', '결과', 'result', 'status', 'pass', 'fail'])]
    for col in result_cols:
        print(f"  {col}: {df[col].unique()[:10]}...")  # 처음 10개만 표시
        print(f"    - 데이터 타입: {df[col].dtype}")
        print(f"    - null 값 개수: {df[col].isnull().sum()}")
    
    print("=" * 50)

# ──────────────────────────────────────────────────────────────────────────────
# 📊 1) 호스트별 보안 수준 막대 차트 (좌상단)
# ──────────────────────────────────────────────────────────────────────────────

def create_host_security_chart(df: pd.DataFrame):
    """📊 호스트별 보안 수준 막대 차트"""
    px, go = get_plotly_modules()
    
    # 호스트별 보안 수준 계산
    host_security = []
    
    for pc_name in df["PC명"].unique():
        host_data = df[df["PC명"] == pc_name]
        
        # 중요도 점수 매핑 (엑셀 분석 결과에 따라)
        importance_scores = {"상": 10, "중": 8, "하": 6}
        
        total_importance = 0
        total_evaluation = 0
        
        for _, row in host_data.iterrows():
            importance = importance_scores.get(row["위험도"], 6)
            total_importance += importance
            
            if row["확인결과"] == "양호":
                total_evaluation += importance
        
        # 보안 수준 = (평가 점수 / 중요도 점수) × 100
        security_level = (total_evaluation / total_importance * 100) if total_importance > 0 else 0
        
        host_security.append({
            'host': pc_name,
            'security_level': round(security_level, 1)
        })
    
    # 보안 수준 낮은 순으로 정렬 (위험한 순서대로)
    host_security.sort(key=lambda x: x['security_level'])
    
    # 파스텔 블루 바이브 색상 매핑
    colors = []
    for item in host_security:
        if item['security_level'] >= 80:
            colors.append('#6C9BCF')  # 파스텔 블루 (양호)
        elif item['security_level'] >= 60:
            colors.append('#A8D8EA')  # 연한 블루 (주의)
        elif item['security_level'] >= 40:
            colors.append('#FFB4B4')  # 연한 핑크 (경고)
        else:
            colors.append('#FF9999')  # 부드러운 빨간색 (위험)
    
    fig = go.Figure(data=[
        go.Bar(
            x=[item['host'] for item in host_security],
            y=[item['security_level'] for item in host_security],
            marker_color=colors,
            text=[f"{item['security_level']}%" for item in host_security],
            textposition='auto',
            hovertemplate='<b>%{x}</b><br>보안 수준: %{y}%<extra></extra>'
        )
    ])
    
    fig.update_layout(
        title="호스트별 보안 수준",
        xaxis_title="호스트명",
        yaxis_title="보안 수준 (%)",
        height=300,
        margin=dict(l=20, r=20, t=40, b=40),
        showlegend=False,
        plot_bgcolor='rgba(248,249,250,0.5)',  # 연한 회색 배경
        paper_bgcolor='rgba(255,255,255,0.9)',  # 흰색 배경
        xaxis=dict(
            tickangle=-45,
            gridcolor='rgba(108,155,207,0.2)',  # 파스텔 블루 그리드
            showgrid=True
        ),
        yaxis=dict(
            gridcolor='rgba(108,155,207,0.2)',  # 파스텔 블루 그리드
            showgrid=True
        ),
        font=dict(color='#2C3E50', family='Arial, sans-serif')  # 깔끔한 폰트
    )
    
    fig.update_yaxes(range=[0, 100])
    
    return fig

# ──────────────────────────────────────────────────────────────────────────────
# 📈 2) 영역별 취약점 현황 도넛 차트 (우상단)
# ──────────────────────────────────────────────────────────────────────────────

def create_area_vulnerability_chart(df: pd.DataFrame):
    """📈 영역별 취약점 현황 도넛 차트 (디버깅 버전)"""
   
    px, go = get_plotly_modules()

    # 영역 코드 → 한글 매핑
    area_mapping = {
        "U1": "계정관리",
        "U2": "파일관리",
        "U3": "서비스관리",
        "U4": "패치관리"
    }

    area_vulns = {}

    print("\n=== [디버깅] 항목코드, 파싱된 area, 확인결과 ===")
    for i, (_, row) in enumerate(df.iterrows()):
        # 1️⃣ 항목코드 읽기
        item_code = str(row.get("진단코드", "")).strip()
        print(f"[{i}] 원본 item_code: '{item_code}'")

            # 안전 파싱
                
        if "-" in item_code:
            prefix, num = item_code.split("-")
            num = str(int(num))  # '01' → '1'
            area_candidate = f"{prefix}{num[0]}"  # 첫 자리만 영역 추출
            if area_candidate in ["U1", "U2", "U3", "U4"]:
                area = area_candidate
            else:
                area = "기타"
        else:
            area = "기타"


        print(f"[{i}] 추출된 area: '{area}'")

        # 3️⃣ 확인결과 읽기
        result = str(row.get("확인결과", "")).strip()
        print(f"[{i}] 확인결과: '{result}'")

        # 4️⃣ area dict 갱신
        if area not in area_vulns:
            area_vulns[area] = {"total": 0, "vuln": 0}

        area_vulns[area]["total"] += 1
        if result == "취약":
            area_vulns[area]["vuln"] += 1

    # 5️⃣ 파싱 결과 요약 출력
    print("\n=== [디버깅] 최종 area_vulns dict ===")
    for area, stats in area_vulns.items():
        print(f"Area: {area} → Total: {stats['total']} | 취약: {stats['vuln']}")

    # ✅ 이후는 원본과 동일: 차트 생성
    labels = []
    values = []
    colors = ['#6C9BCF', '#A8D8EA', '#B8E6B8', '#FFD93D', '#FFB4B4']

    for i, (area, stats) in enumerate(area_vulns.items()):
        area_name = area_mapping.get(area, area)
        vuln_count = stats["vuln"]
        total_count = stats["total"]

        labels.append(f"{area_name}<br>({vuln_count}/{total_count})")
        values.append(vuln_count)

    fig = go.Figure(data=[
        go.Pie(
            labels=labels,
            values=values,
            hole=0.4,
            marker_colors=colors[:len(labels)],
            textinfo='label+percent',
            textposition='auto',
            hovertemplate='<b>%{label}</b><br>취약 항목: %{value}개<br>비율: %{percent}<extra></extra>'
        )
    ])

    fig.update_layout(
        title="영역별 취약점 현황",
        height=300,
        margin=dict(l=20, r=20, t=40, b=20),
        showlegend=False,
        plot_bgcolor='rgba(248,249,250,0.5)',
        paper_bgcolor='rgba(255,255,255,0.9)',
        font=dict(color='#2C3E50', family='Arial, sans-serif')
    )

    return fig

# ──────────────────────────────────────────────────────────────────────────────
# 📉 3) 중요도별 취약점 분포 스택 바 차트 (좌하단) - 개선된 버전
# ──────────────────────────────────────────────────────────────────────────────

def create_severity_distribution_chart(df: pd.DataFrame):
    """📉 중요도별 취약점 분포 스택 바 차트 (개선된 버전)"""
    px, go = get_plotly_modules()
    if px is None or go is None:
        return None
    
    df = df.copy()
    
    # 디버깅 정보 출력
    debug_severity_data(df)
    
    # 1. 위험도 컬럼 찾기 및 매핑
    severity_col = None
    for col in ["위험도", "중요도", "중요도_원본", "severity", "priority", "risk_level"]:
        if col in df.columns and df[col].notnull().any():
            severity_col = col
            break
    
    if severity_col is None:
        print("❌ 위험도 관련 컬럼을 찾을 수 없습니다.")
        return None
    
    print(f"✅ 사용할 위험도 컬럼: {severity_col}")
    print(f"   원본 값들: {df[severity_col].unique()}")
    
    # 2. 유연한 위험도 매핑
    severity_mapping = {
        # 숫자형 (int, str)
        1: "상", 2: "중", 3: "하",
        "1": "상", "2": "중", "3": "하",
        # 영어 (다양한 케이스)
        "high": "상", "medium": "중", "low": "하",
        "High": "상", "Medium": "중", "Low": "하", 
        "HIGH": "상", "MEDIUM": "중", "LOW": "하",
        "h": "상", "m": "중", "l": "하",
        "H": "상", "M": "중", "L": "하",
        # 한글 (이미 변환된 경우)
        "상": "상", "중": "중", "하": "하",
        "높음": "상", "보통": "중", "낮음": "하",
        # 기타 가능한 값들
        "critical": "상", "major": "중", "minor": "하",
        "Critical": "상", "Major": "중", "Minor": "하",
        "CRITICAL": "상", "MAJOR": "중", "MINOR": "하"
    }
    
    df["위험도"] = df[severity_col].map(severity_mapping)
    
    # 3. 확인결과 컬럼 찾기 및 매핑
    result_col = None
    for col in ["확인결과", "결과", "status", "result", "pass_fail"]:
        if col in df.columns and df[col].notnull().any():
            result_col = col
            break
    
    if result_col is None:
        print("❌ 확인결과 관련 컬럼을 찾을 수 없습니다.")
        return None
    
    print(f"✅ 사용할 확인결과 컬럼: {result_col}")
    print(f"   원본 값들: {df[result_col].unique()}")
    
    # 4. 유연한 결과 매핑
    result_mapping = {
        # 영어 (다양한 케이스)
        "pass": "양호", "fail": "취약",
        "PASS": "양호", "FAIL": "취약",
        "Pass": "양호", "Fail": "취약",
        "passed": "양호", "failed": "취약",
        "PASSED": "양호", "FAILED": "취약",
        "ok": "양호", "ng": "취약",
        "OK": "양호", "NG": "취약",
        "success": "양호", "failure": "취약",
        "SUCCESS": "양호", "FAILURE": "취약",
        # 한글 (이미 변환된 경우)
        "양호": "양호", "취약": "취약",
        "정상": "양호", "위험": "취약",
        "안전": "양호", "위험": "취약",
        "통과": "양호", "실패": "취약",
        # 숫자형
        "1": "양호", "0": "취약",
        1: "양호", 0: "취약",
        # True/False
        True: "양호", False: "취약",
        "true": "양호", "false": "취약",
        "True": "양호", "False": "취약",
        "TRUE": "양호", "FALSE": "취약"
    }
    
    # 문자열 변환 후 매핑
    df["확인결과"] = df[result_col].astype(str).str.strip()
    df["확인결과"] = df["확인결과"].map(result_mapping)
    
    # 5. 매핑 결과 확인
    print("\n📊 매핑 결과:")
    print(f"위험도 분포: {df['위험도'].value_counts().to_dict()}")
    print(f"확인결과 분포: {df['확인결과'].value_counts().to_dict()}")
    
    # 매핑되지 않은 값들 확인
    unmapped_severity = df[df["위험도"].isna()][severity_col].unique()
    unmapped_result = df[df["확인결과"].isna()][result_col].unique()
    
    if len(unmapped_severity) > 0:
        print(f"⚠️ 매핑되지 않은 위험도 값들: {unmapped_severity}")
    if len(unmapped_result) > 0:
        print(f"⚠️ 매핑되지 않은 확인결과 값들: {unmapped_result}")
    
    # 6. 유효한 데이터만 필터링
    valid_df = df[
        (df["위험도"].isin(["상", "중", "하"])) & 
        (df["확인결과"].isin(["양호", "취약"]))
    ]
    
    print(f"\n📈 차트 생성용 유효 데이터: {len(valid_df)}/{len(df)} 행")
    
    if len(valid_df) == 0:
        print("❌ 차트 생성에 사용할 수 있는 유효한 데이터가 없습니다.")
        return None
    
    # 7. 통계 계산
    severity_stats = {
        "상": {"양호": 0, "취약": 0},
        "중": {"양호": 0, "취약": 0},
        "하": {"양호": 0, "취약": 0}
    }
    
    for _, row in valid_df.iterrows():
        severity = row["위험도"]
        result = row["확인결과"]
        if severity in severity_stats and result in ["양호", "취약"]:
            severity_stats[severity][result] += 1
    
    print(f"\n📊 최종 통계: {severity_stats}")
    
    # 8. 차트 생성
    categories = list(severity_stats.keys())
    good_counts = [severity_stats[cat]["양호"] for cat in categories]
    vuln_counts = [severity_stats[cat]["취약"] for cat in categories]
    
    # 데이터가 모두 0인지 확인
    if sum(good_counts + vuln_counts) == 0:
        print("❌ 모든 카테고리의 데이터가 0입니다.")
        return None
    
    fig = go.Figure(data=[
        go.Bar(
            name='양호', 
            x=categories, 
            y=good_counts, 
            marker_color='#6C9BCF',
            text=good_counts,
            textposition='inside',
            hovertemplate='<b>%{x} - 양호</b><br>항목 수: %{y}<extra></extra>'
        ),
        go.Bar(
            name='취약', 
            x=categories, 
            y=vuln_counts, 
            marker_color='#FFB4B4',
            text=vuln_counts,
            textposition='inside',
            hovertemplate='<b>%{x} - 취약</b><br>항목 수: %{y}<extra></extra>'
        )
    ])
    
    fig.update_layout(
        title={
            'text': "중요도별 취약점 분포",
            'x': 0.5,
            'xanchor': 'center',
            'font': {'size': 16, 'color': '#2C3E50'}
        },
        barmode='stack',
        xaxis_title="중요도",
        yaxis_title="항목 수",
        height=300,
        margin=dict(l=20, r=20, t=40, b=20),
        plot_bgcolor='rgba(248,249,250,0.5)',
        paper_bgcolor='rgba(255,255,255,0.9)',
        font=dict(color='#2C3E50', family='Arial, sans-serif'),
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=-0.15,
            xanchor="center",
            x=0.5
        )
    )
    
    print("✅ 차트 생성 완료!")
    return fig

# ──────────────────────────────────────────────────────────────────────────────
# 🎯 4) 시간별 보안 개선 추이 라인 차트 (우하단)
# ──────────────────────────────────────────────────────────────────────────────

def create_security_trend_chart(df: pd.DataFrame):
    """🎯 시간별 보안 개선 추이 라인 차트"""
    px, go = get_plotly_modules()
    
    # 호스트별 보안 수준 계산
    hosts = df["PC명"].unique()
    importance_scores = {"상": 10, "중": 8, "하": 6}
    
    # 시간대별 데이터 시뮬레이션 (실제 환경에서는 시계열 데이터 사용)
    time_periods = ["1월", "2월", "3월", "4월", "5월", "6월"]
    
    fig = go.Figure()
    
    # 파스텔 블루 바이브 색상 팔레트
    colors = ['#6C9BCF', '#A8D8EA', '#B8E6B8', '#FFD93D', '#FFB4B4']
    
    for i, host in enumerate(hosts[:4]):  # 상위 4개 호스트만 표시
        host_data = df[df["PC명"] == host]
        
        # 현재 보안 수준 계산
        total_importance = 0
        total_evaluation = 0
        
        for _, row in host_data.iterrows():
            importance = importance_scores.get(row["위험도"], 6)
            total_importance += importance
            
            if row["확인결과"] == "양호":
                total_evaluation += importance
        
        current_level = (total_evaluation / total_importance * 100) if total_importance > 0 else 0
        
        # 트렌드 시뮬레이션 (점진적 개선 가정)
        trend_data = []
        base_level = max(30, current_level - 20)  # 시작점
        
        for j in range(len(time_periods)):
            # 점진적 개선 추이 시뮬레이션
            improvement_rate = j / (len(time_periods) - 1)
            level = base_level + (current_level - base_level) * improvement_rate
            # 약간의 변동성 추가
            variation = (-1) ** j * (5 - j)
            level = max(0, min(100, level + variation))
            trend_data.append(round(level, 1))
        
        fig.add_trace(go.Scatter(
            x=time_periods,
            y=trend_data,
            mode='lines+markers',
            name=host,
            line=dict(color=colors[i % len(colors)], width=2),
            marker=dict(size=6),
            hovertemplate=f'<b>{host}</b><br>기간: %{{x}}<br>보안 수준: %{{y}}%<extra></extra>'
        ))
    
    fig.update_layout(
        title="보안 수준 개선 추이",
        xaxis_title="기간",
        yaxis_title="보안 수준 (%)",
        height=300,
        margin=dict(l=20, r=20, t=40, b=20),
        showlegend=True,
        legend=dict(orientation="h", yanchor="bottom", y=-0.15, x=0.5, xanchor="center"),
        plot_bgcolor='rgba(248,249,250,0.5)',
        paper_bgcolor='rgba(255,255,255,0.9)',
        xaxis=dict(showgrid=True, gridcolor='rgba(108,155,207,0.2)'),
        yaxis=dict(showgrid=True, gridcolor='rgba(108,155,207,0.2)', range=[0, 100]),
        font=dict(color='#2C3E50', family='Arial, sans-serif')
    )
    
    return fig

# ──────────────────────────────────────────────────────────────────────────────
# 🎨 5) 4분할 차트 섹션 생성 함수
# ──────────────────────────────────────────────────────────────────────────────

def create_dashboard_charts_section(df: pd.DataFrame) -> None:
    """4분할 대시보드 차트 섹션 생성"""
    
    st.markdown("---")
    st.markdown("### 📈 종합 보안 분석 대시보드")
    
    # 2x2 그리드 레이아웃
    col1, col2 = st.columns(2)
    
    with col1:
        # 📊 좌상단: 호스트별 보안 수준
        host_security_fig = create_host_security_chart(df)
        st.plotly_chart(host_security_fig, use_container_width=True)
        
    with col2:
        # 📈 우상단: 영역별 취약점 현황  
        area_vuln_fig = create_area_vulnerability_chart(df)
        st.plotly_chart(area_vuln_fig, use_container_width=True, key="area_vuln")
    
    # 두 번째 행
    col3, col4 = st.columns(2)
    
    with col3:
        # 📉 좌하단: 중요도별 취약점 분포
        severity_dist_fig = create_severity_distribution_chart(df)
        st.plotly_chart(severity_dist_fig, use_container_width=True, key="severity_dist")
        
    with col4:
        # 🎯 우하단: 보안 수준 개선 추이
        security_trend_fig = create_security_trend_chart(df)
        st.plotly_chart(security_trend_fig, use_container_width=True, key="security_trend")