"""
Styles 모듈 - 전체 CSS 및 스타일 관리
* 기존: 전체 레이아웃 및 호스트 카드 스타일
* 추가: 메인 페이지 KPI 대시보드 스타일
* 🆕 새로 추가: 모던 카드형 UI 스타일
"""

# ──────────────────────────────────────────────────────────────────────────────
# 1) 전체 레이아웃 스타일 (기존)
# ──────────────────────────────────────────────────────────────────────────────

STYLES = """
<style>
* {font-family:'Nanum Gothic', sans-serif;}

/* 전체 컨테이너 */
.stApp > div:first-child > div:first-child > div:first-child {
    padding-top: 1rem;
}

/* 메인 영역 */
.main-container {
    padding: 2rem;    
}

/* 콘텐츠 영역 - 스크롤 설정 */
.content-area {
    background: white;
    border-radius: 8px;
    padding: 2rem;
    margin-bottom: 2rem;
    max-height: 500px;
    overflow-y: auto;
    border: 1px solid #e0e0e0;
}

/* 커스텀 스크롤바 */
.content-area::-webkit-scrollbar {
    width: 8px;
}

.content-area::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
}

.content-area::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 4px;
}

.content-area::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
}

/* 헤더 영역 */
.header-section {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.header-title {
    font-size: 1.5rem;
    font-weight: bold;
    color: #333;
}

/* 호스트 그리드 */
.host-grid {
    width: 100%;
}

.host-row {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
}

.host-col {
    flex: 1;
}

/* 호스트 카드 */
.host-card {
    background: #9e9e9e;
    color: white;
    border-radius: 12px;
    padding: 1.5rem;
    text-align: center;
    min-height: 150px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
}

.host-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

.host-card img {
    width: 48px;
    height: 48px;
    margin-bottom: 0.8rem;
    object-fit: contain;
}

.host-card .host-info {
    line-height: 1.4;
}

.host-card .host-info div {
    margin: 3px 0;
    font-size: 14px;
}

/* 실행 버튼 영역 */
.run-button-container {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    z-index: 1000;
}

/* Streamlit 기본 스타일 조정 */
.stButton > button {
    background-color: #666;
    color: white;
    border: none;
    padding: 0.5rem 2rem;
    border-radius: 4px;
    font-size: 14px;
}

.stButton > button:hover {
    background-color: #555;
}

/* 사이드바 숨기기 */
.css-1d391kg {
    display: none;
}

/* 여백 조정 */
.block-container {
    padding-top: 1rem;
    padding-bottom: 1rem;
}

/* 스크롤 영역 내부 여백 */
.element-container {
    margin-bottom: 0.5rem;
}
</style>
"""

# ──────────────────────────────────────────────────────────────────────────────
# 2) 🆕 모던 카드형 UI 스타일 (메인 페이지 전용 - 대폭 개선)
# ──────────────────────────────────────────────────────────────────────────────

MAIN_PAGE_CSS = """
<style>
/* 🎨 전체 앱 배경 - 파스텔 블루 그라데이션 */
.stApp {
    background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
    min-height: 100vh;
}

/* 메인 컨테이너 */
.main .block-container {
    padding: 1rem 2rem;
    max-width: 1200px;
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 KPI 카드 스타일 (개선된 버전) */
/* ──────────────────────────────────────────────────────────────────────── */

.kpi-card-modern {
    background: linear-gradient(145deg, #ffffff 0%, #f8fafc 100%);
    border-radius: 16px;
    padding: 24px;
    margin: 8px 0;
    box-shadow: 
        0 4px 6px -1px rgba(0, 0, 0, 0.1),
        0 2px 4px -1px rgba(0, 0, 0, 0.06);
    border: 1px solid rgba(59, 130, 246, 0.1);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
}

.kpi-card-modern::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, #3b82f6, #1d4ed8);
    border-radius: 16px 16px 0 0;
}

.kpi-card-modern:hover {
    transform: translateY(-4px);
    box-shadow: 
        0 10px 25px -3px rgba(0, 0, 0, 0.1),
        0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.kpi-icon {
    font-size: 2.5rem;
    margin-bottom: 12px;
    opacity: 0.8;
}

.kpi-title {
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.kpi-value {
    font-size: 2.5rem;
    font-weight: 700;
    margin: 8px 0;
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.kpi-unit {
    font-size: 12px;
    color: #94a3b8;
    font-weight: 500;
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 서버 카드 스타일 (완전히 새로운 디자인) */
/* ──────────────────────────────────────────────────────────────────────── */

.server-card-modern {
    background: white;
    border-radius: 12px;
    padding: 16px;
    margin: 8px 0;
    border: 1px solid #e2e8f0;
    box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
    transition: all 0.2s ease;
    cursor: pointer;
    position: relative;
}

.server-card-modern:hover {
    transform: translateX(4px);
    box-shadow: 0 4px 12px 0 rgba(0, 0, 0, 0.15);
    border-color: #3b82f6;
}

.server-card-modern::before {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 4px;
    background: var(--accent-color, #3b82f6);
    border-radius: 12px 0 0 12px;
    transition: width 0.2s ease;
}

.server-card-modern:hover::before {
    width: 6px;
}

.server-info {
    display: flex;
    align-items: center;
    gap: 12px;
}

.server-icon {
    font-size: 1.5rem;
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(59, 130, 246, 0.1);
    border-radius: 8px;
}

.server-content {
    flex: 1;
}

.server-name {
    font-weight: 600;
    font-size: 15px;
    color: #1e293b;
    margin-bottom: 4px;
}

.server-subtitle {
    font-size: 13px;
    color: #64748b;
}

.server-value {
    font-weight: 700;
    font-size: 18px;
    padding: 4px 12px;
    border-radius: 20px;
    background: rgba(59, 130, 246, 0.1);
    color: #1d4ed8;
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 액션 버튼 스타일 (블록형) */
/* ──────────────────────────────────────────────────────────────────────── */

.action-button {
    background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 14px 24px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 14px 0 rgba(59, 130, 246, 0.4);
    text-transform: none;
    letter-spacing: 0.5px;
}

.action-button:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px 0 rgba(59, 130, 246, 0.5);
    background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
}

.action-button:active {
    transform: translateY(0);
}

/* Streamlit 버튼 오버라이드 */
.stButton > button {
    background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%) !important;
    color: white !important;
    border: none !important;
    border-radius: 12px !important;
    padding: 14px 24px !important;
    font-size: 15px !important;
    font-weight: 600 !important;
    transition: all 0.3s ease !important;
    box-shadow: 0 4px 14px 0 rgba(59, 130, 246, 0.4) !important;
    height: auto !important;
}

.stButton > button:hover {
    transform: translateY(-2px) !important;
    box-shadow: 0 8px 25px 0 rgba(59, 130, 246, 0.5) !important;
    background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%) !important;
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 카드 그리드 레이아웃 (가로 스크롤) */
/* ──────────────────────────────────────────────────────────────────────── */

.card-grid-container {
    background: white;
    border-radius: 16px;
    padding: 24px;
    margin: 16px 0;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(59, 130, 246, 0.1);
}

.card-grid {
    display: flex;
    gap: 16px;
    overflow-x: auto;
    padding: 8px 0;
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 #f1f5f9;
}

.card-grid::-webkit-scrollbar {
    height: 8px;
}

.card-grid::-webkit-scrollbar-track {
    background: #f1f5f9;
    border-radius: 4px;
}

.card-grid::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 4px;
}

.card-grid::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}

.card-item {
    min-width: 250px;
    background: white;
    border-radius: 12px;
    padding: 20px;
    border: 2px solid #e2e8f0;
    transition: all 0.3s ease;
    cursor: pointer;
}

.card-item:hover {
    border-color: #3b82f6;
    transform: translateY(-4px);
    box-shadow: 0 8px 25px rgba(59, 130, 246, 0.15);
}

.card-item.selected {
    border-color: #1d4ed8;
    background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 체크박스 및 라디오 버튼 스타일 */
/* ──────────────────────────────────────────────────────────────────────── */

.custom-checkbox {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: white;
    border-radius: 8px;
    border: 2px solid #e2e8f0;
    cursor: pointer;
    transition: all 0.2s ease;
    margin: 4px 0;
}

.custom-checkbox:hover {
    border-color: #3b82f6;
    background: #f8fafc;
}

.custom-checkbox.checked {
    border-color: #1d4ed8;
    background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
}

.checkbox-icon {
    width: 20px;
    height: 20px;
    border-radius: 4px;
    border: 2px solid #cbd5e1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    color: white;
    background: white;
    transition: all 0.2s ease;
}

.checkbox-icon.checked {
    background: #3b82f6;
    border-color: #3b82f6;
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 섹션 제목 및 구분선 */
/* ──────────────────────────────────────────────────────────────────────── */

.section-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1e293b;
    margin: 32px 0 16px 0;
    padding-bottom: 8px;
    border-bottom: 3px solid #3b82f6;
    display: inline-block;
}

.section-subtitle {
    font-size: 1.1rem;
    font-weight: 600;
    color: #475569;
    margin: 24px 0 12px 0;
}

.divider {
    height: 1px;
    background: linear-gradient(90deg, transparent, #cbd5e1, transparent);
    margin: 24px 0;
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 반응형 디자인 */
/* ──────────────────────────────────────────────────────────────────────── */

@media (max-width: 768px) {
    .card-grid {
        flex-direction: column;
    }
    
    .card-item {
        min-width: 100%;
    }
    
    .kpi-value {
        font-size: 2rem;
    }
    
    .main .block-container {
        padding: 1rem;
    }
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 애니메이션 */
/* ──────────────────────────────────────────────────────────────────────── */

@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.fade-in-up {
    animation: fadeInUp 0.6s ease-out;
}

@keyframes pulse {
    0%, 100% {
        opacity: 1;
    }
    50% {
        opacity: 0.7;
    }
}

.pulse {
    animation: pulse 2s infinite;
}
</style>
"""

# ──────────────────────────────────────────────────────────────────────────────
# 3) 색상 상수 정의 (기존 + 확장)
# ──────────────────────────────────────────────────────────────────────────────

COLORS = {
    "primary": "#3b82f6",      # 모던 블루
    "primary_dark": "#1d4ed8", # 진한 블루
    "good": "#10b981",         # 에메랄드 그린
    "warning": "#f59e0b",      # 앰버
    "danger": "#ef4444",       # 레드
    "info": "#8b5cf6",         # 바이올렛
    "muted": "#64748b",        # 슬레이트
    "background": "#f8fafc",   # 라이트 그레이
    "card": "#ffffff",         # 화이트
    "border": "#e2e8f0",       # 라이트 보더
}

# 위험도별 색상 매핑 (업데이트)
RISK_COLORS = {
    "low": COLORS["good"],     # 에메랄드 그린 - 낮은 위험
    "medium": COLORS["warning"], # 앰버 - 보통 위험  
    "high": COLORS["danger"],  # 레드 - 높은 위험
}

# ──────────────────────────────────────────────────────────────────────────────
# 4) 스타일 헬퍼 함수들 (업데이트 + 확장)
# ──────────────────────────────────────────────────────────────────────────────

def get_risk_color_and_icon(vuln_ratio: float) -> tuple[str, str]:
    """
    취약률에 따른 색상과 아이콘 반환
    
    Args:
        vuln_ratio: 취약률 (0-100)
        
    Returns:
        tuple: (색상, 아이콘)
    """
    if vuln_ratio >= 60:
        return COLORS["danger"], "🔴"
    elif vuln_ratio >= 40:
        return COLORS["warning"], "🟡"
    else:
        return COLORS["good"], "🟢"

def kpi_card_style(color: str) -> str:
    """
    모던 KPI 카드의 인라인 스타일 생성
    
    Args:
        color: 메인 색상 (hex code)
        
    Returns:
        str: 인라인 스타일 문자열
    """
    return f"""
        background: linear-gradient(145deg, #ffffff 0%, #f8fafc 100%);
        border-radius: 16px;
        padding: 24px;
        margin: 8px 0;
        box-shadow: 
            0 4px 6px -1px rgba(0, 0, 0, 0.1),
            0 2px 4px -1px rgba(0, 0, 0, 0.06);
        border: 1px solid rgba(59, 130, 246, 0.1);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        text-align: center;
        position: relative;
        --accent-color: {color};
    """

def server_card_style(color: str) -> str:
    """
    모던 서버 카드의 인라인 스타일 생성
    
    Args:
        color: 좌측 테두리 색상 (hex code)
        
    Returns:
        str: 인라인 스타일 문자열
    """
    return f"""
        background: white;
        border-radius: 12px;
        padding: 16px;
        margin: 8px 0;
        border: 1px solid #e2e8f0;
        border-left: 4px solid {color};
        box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
        transition: all 0.2s ease;
        cursor: pointer;
        --accent-color: {color};
    """

def create_card_grid_html(items: list, selected_items: list = None) -> str:
    """
    가로 스크롤 카드 그리드 HTML 생성
    
    Args:
        items: 카드 아이템 리스트 [{'title': str, 'value': str, 'icon': str, 'id': str}]
        selected_items: 선택된 아이템 ID 리스트
        
    Returns:
        str: 카드 그리드 HTML
    """
    if selected_items is None:
        selected_items = []
        
    cards_html = ""
    for item in items:
        selected_class = "selected" if item.get('id') in selected_items else ""
        cards_html += f"""
        <div class="card-item {selected_class}" onclick="selectCard('{item.get('id', '')}')">
            <div class="kpi-icon">{item.get('icon', '📊')}</div>
            <div class="kpi-title">{item.get('title', '')}</div>
            <div class="kpi-value">{item.get('value', '')}</div>
        </div>
        """
    
    return f"""
    <div class="card-grid-container">
        <div class="card-grid">
            {cards_html}
        </div>
    </div>
    """

def create_action_button(text: str, onclick: str = "", style: str = "") -> str:
    """
    모던 액션 버튼 HTML 생성
    
    Args:
        text: 버튼 텍스트
        onclick: 클릭 이벤트 (선택사항)
        style: 추가 스타일 (선택사항)
        
    Returns:
        str: 버튼 HTML
    """
    onclick_attr = f'onclick="{onclick}"' if onclick else ""
    style_attr = f'style="{style}"' if style else ""
    
    return f"""
    <button class="action-button" {onclick_attr} {style_attr}>
        {text}
    </button>
    """

# ──────────────────────────────────────────────────────────────────────────────
# 5) Plotly 색상 (기존 유지)
# ──────────────────────────────────────────────────────────────────────────────

# Plotly 게이지에서 사용하는 색상들 (업데이트된 COLORS 반영)
GAUGE_COLORS = {
    "green": COLORS["good"],      # "#10b981"
    "orange": COLORS["warning"],  # "#f59e0b" 
    "red": COLORS["danger"],      # "#ef4444"
}

# RGBA 형태의 색상 (투명도 포함)
GAUGE_COLORS_RGBA = {
    "green": "rgba(16,185,129,0.3)",
    "orange": "rgba(245,158,11,0.3)", 
    "red": "rgba(239,68,68,0.3)",
}