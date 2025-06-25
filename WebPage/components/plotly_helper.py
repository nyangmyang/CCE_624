
"""
Plotly 헬퍼 모듈 - 차트 생성 및 시각화 관리
* 2025-06-21 • page_1_main_page.py에서 Plotly 관련 코드 분리
* 주요 기능:
    1. Plotly 지연 import 및 캐싱
    2. 보안 대시보드용 게이지 차트 생성
    3. 서버별 취약점 트렌드 차트 생성
    4. 샘플 데이터 차트 생성
"""

from functools import lru_cache
from datetime import datetime
import pandas as pd
import streamlit as st

# ──────────────────────────────────────────────────────────────────────────────
# 1) Plotly 지연 import 및 캐싱
# ──────────────────────────────────────────────────────────────────────────────

@st.cache_resource(show_spinner=False)
def get_plotly_modules():
    """
    Plotly 관련 모듈을 지연 import 하고 캐싱
    
    Returns:
        tuple: (px, go) - plotly.express, plotly.graph_objects
    """
    import plotly.express as px
    import plotly.graph_objects as go
    return px, go

# ──────────────────────────────────────────────────────────────────────────────
# 2) 게이지 차트 생성
# ──────────────────────────────────────────────────────────────────────────────

def create_semicircle_gauge(vuln_ratio: float, total_items: int = 0, gauge_colors: dict = None) -> object:
    """
    취약점 비율을 기반으로 반원형 게이지 차트 생성
    
    Args:
        vuln_ratio: 취약 비율 (0-100)
        total_items: 전체 점검 항목 수
        gauge_colors: 게이지 색상 딕셔너리 {green, orange, red}
        
    Returns:
        go.Figure: Plotly 게이지 차트 객체
    """
    px, go = get_plotly_modules()
    
    # 기본 색상 설정
    if gauge_colors is None:
        gauge_colors = {
            "green": "#7ED321",
            "orange": "#F5A623", 
            "red": "#D0021B"
        }
    
    gauge_colors_rgba = {
        "green": "rgba(126,211,33,0.3)",
        "orange": "rgba(245,166,35,0.3)",
        "red": "rgba(208,2,27,0.3)"
    }
    
    # 취약 항목 개수 계산
    vuln_count = int(vuln_ratio * total_items / 100) if total_items > 0 else 0

    # 색상 결정 (취약률에 따라)
    if vuln_ratio > 66:
        bar_color = gauge_colors["red"]
    elif vuln_ratio > 33:
        bar_color = gauge_colors["orange"]
    else:
        bar_color = gauge_colors["green"]

    # 현재 시간 계산
    current_time = datetime.now().strftime('%H:%M:%S')

    fig = go.Figure(
        go.Indicator(
            mode="gauge+number",
            value=vuln_ratio,
            domain={"x": [0.1, 0.9], "y": [0.1, 0.9]},
            title={
                'text': f"<b>취약점 현황</b><br><span style='font-size:14px;color:#666'>{vuln_count}개 항목 취약</span>",
               'align':"center", 
                'font': {'size': 18},
               
            },
            number={'suffix': "%"},
            gauge={
                "axis": {
                    "range": [0, 100],
                    'tickwidth': 1,
                    'tickcolor': "darkblue"
                },
                "bar": {"color": bar_color,"thickness": 0.8},
                "steps": [
                    {"range": [0, 33], "color": gauge_colors_rgba["green"]},
                    {"range": [33, 66], "color": gauge_colors_rgba["orange"]},
                    {"range": [66, 100], "color": gauge_colors_rgba["red"]},
                ],
                'threshold': {
                    'line': {'color': "red", 'width': 4},
                    'thickness': 0.75,
                    'value': 50
                }
            }
        )
    )
    #중심 정렬 및 배경 투명 처리
    fig.update_layout(
    margin=dict(t=60, b=20, l=50, r=50),
    height=280,
    font={'color': "darkblue", 'family': "Arial"},
          # 제목 중앙 정렬
    showlegend=False, #범례 숨기기
    # 🆕 라운드 스타일 추가
    plot_bgcolor='rgba(0,0,0,0)',
    paper_bgcolor='rgba(0,0,0,0)',
    
    # 차트 자체도 둥글게
    shapes=[
        dict(
            type="rect",
            xref="paper", yref="paper",
            x0=0, y0=0, x1=1, y1=1,
            line=dict(color="rgba(0,0,0,0)", width=0),
            fillcolor="rgba(0,0,0,0)",
        )
    ]
)
    
    return fig

# ──────────────────────────────────────────────────────────────────────────────
# 3) 서버별 취약점 트렌드 차트 (실제 시간 사용!)
# ──────────────────────────────────────────────────────────────────────────────
def create_server_trend_chart(df: pd.DataFrame) -> object:
    """
    ✅ 서버별 날짜별 평균 위험도 점수 트렌드 차트
    High=3, Medium=2, Low=1 로 가중 평균
    """
    px, go = get_plotly_modules()

    if df.empty:
        return go.Figure().add_annotation(text="데이터가 없습니다", x=0.5, y=0.5)

    # 1️⃣ 위험도 점수 매핑
    df['RiskScore'] = df['위험도'].map({'높음': 3, '보통': 2, '낮음': 1}).fillna(0)
    df['Date'] = pd.to_datetime(df['진단시점']).dt.date

    # 2️⃣ [PC명, Date]별 평균 위험도 점수 계산
    grouped = df[df['확인결과'] == '취약'].groupby(['PC명', 'Date']).agg(
        total_score=('RiskScore', 'sum'),
        item_count=('RiskScore', 'count')
    ).reset_index()
    grouped['avg_risk'] = grouped['total_score'] / grouped['item_count']

    # 3️⃣ Plotly 선 그래프
    fig = go.Figure()
    servers = grouped['PC명'].unique()
    colors = px.colors.qualitative.Set1[:len(servers)]

    for i, server in enumerate(servers):
        server_data = grouped[grouped['PC명'] == server].sort_values('Date')

        fig.add_trace(go.Scatter(
            x=server_data['Date'],
            y=server_data['avg_risk'],
            mode='lines+markers',
            name=server,
            line=dict(color=colors[i], width=2),
            marker=dict(size=6)
        ))

    fig.update_layout(
        title='📈 서버별 평균 위험도 점수 트렌드',
        xaxis_title='Date',
        yaxis_title='평균 위험도 점수 (High=3 ~ Low=1)',
        height=500,
        hovermode='x unified',
        plot_bgcolor='rgba(248,250,252,0.5)',
        paper_bgcolor='rgba(0,0,0,0)',
        legend=dict(
            orientation="v",
            yanchor="top",
            y=1,
            xanchor="left",
            x=1.02,
            bgcolor="rgba(255,255,255,0.9)",
            bordercolor="rgba(59, 130, 246, 0.2)",
            borderwidth=1
        ),
        margin=dict(r=200)
    )

    return fig


# ──────────────────────────────────────────────────────────────────────────────
# 4) 샘플 데이터 차트 생성
# ──────────────────────────────────────────────────────────────────────────────

def create_sample_server_trend_chart() -> object:
    """
    샘플 데이터로 서버별 트렌드 차트 생성
    
    Returns:
        go.Figure: Plotly 라인 차트 객체 (샘플 데이터)
    """
    px, go = get_plotly_modules()
    
    # 샘플 데이터
    sample_data = [
        {'Date': pd.Timestamp('2025-06-15').date(), 'Server': 'PC-10', 'High': 18, 'Medium': 3, 'Low': 0},
        {'Date': pd.Timestamp('2025-06-17').date(), 'Server': 'PC-25', 'High': 12, 'Medium': 4, 'Low': 2},
        {'Date': pd.Timestamp('2025-06-19').date(), 'Server': 'PC-55', 'High': 6, 'Medium': 6, 'Low': 3},
        {'Date': pd.Timestamp('2025-06-21').date(), 'Server': 'PC-88', 'High': 2, 'Medium': 3, 'Low': 2}
    ]
    
    trend_df = pd.DataFrame(sample_data)
    fig = go.Figure()
    
    servers = trend_df['Server'].unique()
    server_colors = px.colors.qualitative.Set1[:len(servers)]
    
    for i, server in enumerate(servers):
        server_data = trend_df[trend_df['Server'] == server]
        
        for risk_level, line_style in [
            ('High', {'width': 3, 'dash': 'solid', 'marker_size': 8}),
            ('Medium', {'width': 2, 'dash': 'dash', 'marker_size': 6}),
            ('Low', {'width': 1, 'dash': 'dot', 'marker_size': 4})
        ]:
            fig.add_trace(go.Scatter(
                x=server_data['Date'],
                y=server_data[risk_level],
                mode='lines+markers',
                name=f'{server} ({risk_level})',
                line=dict(
                    color=server_colors[i], 
                    width=line_style['width'], 
                    dash=line_style['dash']
                ),
                marker=dict(size=line_style['marker_size'])
            ))
    
    fig.update_layout(
        title='Sample: Server Vulnerability Trends by Risk Level',
        xaxis_title='Date',
        yaxis_title='Vulnerability Count', 
        height=400,
        legend=dict(orientation="v", yanchor="top", y=1, xanchor="left", x=1.02),
        margin=dict(r=150)
    )
    
    return fig

# ──────────────────────────────────────────────────────────────────────────────
# 5) 편의 함수들
# ──────────────────────────────────────────────────────────────────────────────

def create_vulnerability_gauge(vuln_ratio: float, total_items: int = 0) -> object:
    """
    취약점 게이지 차트 생성 (외부 호출용 래퍼 함수)
    
    Args:
        vuln_ratio: 취약 비율 (0-100)
        total_items: 전체 점검 항목 수
        
    Returns:
        go.Figure: Plotly 게이지 차트
    """
    return create_semicircle_gauge(vuln_ratio, total_items)

def create_trend_chart(df: pd.DataFrame) -> object:
    """
    트렌드 차트 생성 (외부 호출용 래퍼 함수)
    
    Args:
        df: 보안 점검 결과 DataFrame
        
    Returns:
        go.Figure: Plotly 라인 차트
    """
    return create_server_trend_chart(df)

