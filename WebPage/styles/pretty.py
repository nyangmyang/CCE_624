"""
내가 작성한 스타일 모듈
* 모던 카드형 UI 스타일
* KPI 대시보드 스타일  
* 색상 정의 및 헬퍼 함수들
"""

# ──────────────────────────────────────────────────────────────────────────────
# 1) 🆕 모던 카드형 UI 스타일 (메인 페이지 전용 - 대폭 개선)
# ──────────────────────────────────────────────────────────────────────────────

MAIN_PAGE_CSS = """
<style>
/* 🎨 전체 앱 배경 */
.stApp {
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    min-height: 100vh;
}

/* 메인 컨테이너 */
.main .block-container {
    padding: 1rem 2rem;
    max-width: 1200px;
}
* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 섹션 컨테이너 스타일 (라운드 연파랑 배경) */
/* ──────────────────────────────────────────────────────────────────────── */

.section-container {
    background: linear-gradient(145deg, rgba(219, 234, 254, 0.6) 0%, rgba(239, 246, 255, 0.8) 100%);
    border-radius: 24px;
    padding: 32px;
    margin: 24px 0;
    box-shadow: 
        0 8px 25px -5px rgba(59, 130, 246, 0.15),
        0 4px 10px -2px rgba(0, 0, 0, 0.05);
    border: 1px solid rgba(59, 130, 246, 0.2);
    backdrop-filter: blur(10px);
    transition: all 0.3s ease;
}

.section-container:hover {
    transform: translateY(-2px);
    box-shadow: 
        0 12px 35px -8px rgba(59, 130, 246, 0.2),
        0 6px 15px -3px rgba(0, 0, 0, 0.08);
}

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 KPI 카드 스타일 (개선된 버전) */
/* ──────────────────────────────────────────────────────────────────────── */

.kpi-card-modern {
    background: linear-gradient(145deg, #ffffff 0%, #f8fafc 100%);
    border-radius: 24px;
    padding: 28px;
    margin: 12px 0;
    box-shadow: 
        0 8px 25px -5px rgba(0, 0, 0, 0.1),
        0 4px 10px -2px rgba(0, 0, 0, 0.05);
    border: 1px solid rgba(59, 130, 246, 0.08);
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
}

.kpi-card-modern::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 6px;
    background: linear-gradient(90deg, #3b82f6, #1d4ed8);
    border-radius: 24px 24px 0 0;
}

.kpi-card-modern:hover {
    transform: translateY(-6px);
    box-shadow: 
        0 15px 35px -5px rgba(0, 0, 0, 0.15),
        0 8px 15px -3px rgba(0, 0, 0, 0.08);
}

.server-card-modern {
    background: linear-gradient(145deg, #ffffff 0%, #f9fafb 100%);
    border-radius: 20px;
    padding: 24px;
    margin: 12px 0;
    border: 1px solid rgba(226, 232, 240, 0.6);
    box-shadow: 
        0 4px 15px -3px rgba(0, 0, 0, 0.08),
        0 2px 8px -1px rgba(0, 0, 0, 0.04);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
    position: relative;
    overflow: hidden;
}

.server-card-modern:hover {
    transform: translateY(-3px);
    box-shadow: 
        0 12px 30px -8px rgba(0, 0, 0, 0.15),
        0 6px 15px -3px rgba(0, 0, 0, 0.08);
    border-color: rgba(59, 130, 246, 0.3);
}

.server-card-modern::before {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 6px;
    background: var(--accent-color, #3b82f6);
    border-radius: 20px 0 0 20px;
    transition: width 0.3s ease;
}

.server-card-modern:hover::before {
    width: 10px;
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

/* Streamlit 기본 제목들 스타일링 */
.stMarkdown h1 {
    font-size: 3rem !important;
    font-weight: 900 !important;
    color: #1e40af !important;
    margin-bottom: 1rem !important;
}

.stMarkdown h2 {
    font-size: 2.5rem !important;
    font-weight: 900 !important;
    color: #1e40af !important;
    margin-bottom: 1rem !important;
}

.main .stMarkdown h3 {                    /* ### 제목들 */
    font-size: 2rem !important;
    font-weight: 900 !important;
    color: #1e40af !important;
    margin-bottom: 0.8rem !important;
}

.main .stMarkdown h4 {
    font-size: 1.6rem !important;
    font-weight: 900 !important;
    color: #1e40af !important;
    margin-bottom: 0.6rem !important;
}

.main .stMarkdown h5 {                    /* ##### 제목들 */
    font-size: 1.3rem !important;
    font-weight: 900 !important;
    color: #1e40af !important;
    margin-bottom: 0.5rem !important;
}

/* 사이드바는 기본 크기로 유지 */
.css-1d391kg .stMarkdown h3,              /* 사이드바 선택자 */
.css-1d391kg .stMarkdown h5 {
    font-size: 1rem !important;
    font-weight: 600 !important;
    color: #374151 !important;
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

/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 Plotly 차트 라운드 스타일 및 호스트 카드 그라데이션 */
/* ──────────────────────────────────────────────────────────────────────── */

/* Plotly 차트 컨테이너 라운드 처리 */
.stPlotlyChart {
    background: white !important;
    border-radius: 24px !important;
    padding: 24px !important;
    box-shadow: 0 8px 25px -5px rgba(0, 0, 0, 0.1) !important;
    border: 1px solid rgba(59, 130, 246, 0.08) !important;
    margin: 16px 0 !important;
    overflow: hidden !important;
}

.js-plotly-plot {
    border-radius: 20px !important;
}

/* 호스트 카드 그라데이션 배경 (이미지 스타일) */
.host-card-gradient {
    background: linear-gradient(135deg, 
        rgba(219, 234, 254, 0.8) 0%,
        rgba(239, 246, 255, 0.6) 50%,
        rgba(255, 255, 255, 0.8) 100%);
    
    border-radius: 20px;
    padding: 24px;
    margin: 12px;
    
    box-shadow: 
        0 8px 25px -8px rgba(59, 130, 246, 0.2),
        0 4px 12px -2px rgba(0, 0, 0, 0.05);
    
    border: 1px solid rgba(59, 130, 246, 0.1);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
    position: relative;
    backdrop-filter: blur(10px);
}

.host-card-gradient:hover {
    transform: translateY(-4px) scale(1.02);
    box-shadow: 
        0 15px 35px -10px rgba(59, 130, 246, 0.3),
        0 8px 20px -4px rgba(0, 0, 0, 0.1);
}
/* 사이드바 제목 크기 조정 */
.stSidebar h1, .stSidebar h2, .stSidebar h3 {
    font-size: 1.1rem !important;
    font-weight: 600 !important;
    color: #64748b !important;
    margin-bottom: 0.8rem !important;
}

/* 사이드바 전체 폰트 조정 */
.stSidebar {
    font-size: 14px !important;
}

/* 사이드바 상태 표시 박스 스타일 */
.stSidebar .stAlert {
    font-size: 13px !important;
    padding: 8px 12px !important;
    margin: 4px 0 !important;
}
/* ──────────────────────────────────────────────────────────────────────── */
/* 🔷 박스형 스크롤 가능한 서버 리스트 컨테이너 */
/* ──────────────────────────────────────────────────────────────────────── */

.server-box-container {
    background: white;
    border-radius: 16px;
    border: 2px solid #e5e7eb;
    margin: 16px 0;
    box-shadow: 
        0 4px 15px -4px rgba(0, 0, 0, 0.1),
        0 2px 8px -2px rgba(0, 0, 0, 0.05);
    overflow: hidden;
    max-height: 480px; /* 전체 박스 최대 높이 */
}

.server-box-header {
    background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
    border-bottom: 2px solid #e5e7eb;
    padding: 16px 20px;
    position: sticky;
    top: 0;
    z-index: 10;
}

.server-box-content {
    max-height: 380px; /* 헤더를 제외한 콘텐츠 높이 */
    overflow-y: auto;
    overflow-x: hidden;
    padding: 8px;
}

/* 서버 리스트 아이템 스타일 */
.server-list-item {
    background: white;
    border-radius: 12px;
    padding: 16px;
    margin: 8px 4px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 2px 8px -2px rgba(0, 0, 0, 0.08);
    transition: all 0.3s ease;
    cursor: pointer;
}

.server-list-item:hover {
    transform: translateX(4px);
    box-shadow: 0 4px 15px -3px rgba(0, 0, 0, 0.15);
    border-color: #3b82f6;
    background: #fafbfc;
}

/* 박스 스타일 스크롤바 */
.server-box-content::-webkit-scrollbar {
    width: 6px;
}

.server-box-content::-webkit-scrollbar-track {
    background: #f1f5f9;
    border-radius: 3px;
    margin: 4px 0;
}

.server-box-content::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 3px;
}

.server-box-content::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}

/* Firefox용 스크롤바 */
.server-box-content {
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 #f1f5f9;
}

/* 호버 효과가 있는 서버 카드 (기존 스타일 개선) */
.host-card-gradient {
    background: linear-gradient(135deg, 
        rgba(219, 234, 254, 0.8) 0%,
        rgba(239, 246, 255, 0.6) 50%,
        rgba(255, 255, 255, 0.8) 100%);
    
    border-radius: 16px;
    padding: 20px;
    margin: 8px 0;
    
    box-shadow: 
        0 4px 15px -8px rgba(59, 130, 246, 0.2),
        0 2px 8px -2px rgba(0, 0, 0, 0.05);
    
    border: 1px solid rgba(59, 130, 246, 0.1);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
    position: relative;
    backdrop-filter: blur(10px);
    display: flex;
    align-items: center;
    gap: 16px;
}

.host-card-gradient:hover {
    transform: translateX(8px) translateY(-2px);
    box-shadow: 
        0 8px 25px -10px rgba(59, 130, 246, 0.3),
        0 4px 15px -4px rgba(0, 0, 0, 0.1);
    border-color: rgba(59, 130, 246, 0.3);
}

/* 스크롤 시 보이는 그라데이션 효과 */
.scrollable-server-container::before {
    content: '';
    position: absolute;
    top: 80px;
    left: 24px;
    right: 24px;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.2), transparent);
    pointer-events: none;
    z-index: 1;
}

.scrollable-server-container::after {
    content: '';
    position: absolute;
    bottom: 24px;
    left: 24px;
    right: 24px;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.2), transparent);
    pointer-events: none;
    z-index: 1;
}

</style>
"""

# ──────────────────────────────────────────────────────────────────────────────
# 2) 색상 상수 정의
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

# 위험도별 색상 매핑
RISK_COLORS = {
    "low": COLORS["good"],     # 에메랄드 그린 - 낮은 위험
    "medium": COLORS["warning"], # 앰버 - 보통 위험  
    "high": COLORS["danger"],  # 레드 - 높은 위험
}

# ──────────────────────────────────────────────────────────────────────────────
# 3) 스타일 헬퍼 함수들
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
    라운드 KPI 카드 박스의 인라인 스타일 생성
    
    Args:
        color: 메인 색상 (hex code)
        
    Returns:
        str: 인라인 스타일 문자열
    """
    return f"""
        background: linear-gradient(145deg, #ffffff 0%, #f8fafc 100%);
        border-radius: 24px;
        padding: 28px;
        margin: 12px 0;
        box-shadow: 
            0 8px 25px -5px rgba(0, 0, 0, 0.1),
            0 4px 10px -2px rgba(0, 0, 0, 0.05);
        border: 1px solid rgba(59, 130, 246, 0.08);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        text-align: center;
        position: relative;
        --accent-color: {color};
        overflow: hidden;
    """

def server_card_style(color: str) -> str:
    """
    라운드 서버 카드의 인라인 스타일 생성
    
    Args:
        color: 좌측 테두리 색상 (hex code)
        
    Returns:
        str: 인라인 스타일 문자열
    """
    return f"""
        background: linear-gradient(145deg, #ffffff 0%, #f9fafb 100%);
        border-radius: 20px;
        padding: 24px;
        margin: 12px 0;
        border: 1px solid rgba(226, 232, 240, 0.6);
        border-left: 6px solid {color};
        box-shadow: 
            0 4px 15px -3px rgba(0, 0, 0, 0.08),
            0 2px 8px -1px rgba(0, 0, 0, 0.04);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        cursor: pointer;
        --accent-color: {color};
        position: relative;
        overflow: hidden;
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
# 4) Plotly 색상
# ──────────────────────────────────────────────────────────────────────────────

# Plotly 게이지에서 사용하는 색상들
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