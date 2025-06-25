PAGE3_STYLE = """
<style>
*{font-family:'Nanum Gothic',sans-serif;}
.page-title{display:flex;align-items:center;margin:20px 0 30px;border-bottom:2px solid #e0e0e0}
.page-icon{font-size:32px;margin-right:15px;color:#2196f3}
.page-title h1{margin:0;font-size:28px;color:#333;font-weight:bold}
.actions-section{background:#f8f9fa;border:none}
.table-scroll{max-height:500px;overflow-y:auto;width:100%;}

/* KPI 카드 */
.kpi-card {background:rgba(99,102,241,0.07);border-radius:18px;padding:1.2rem 0.5rem 1rem 0.5rem;box-shadow:0 2px 12px #6366f122;text-align:center;}
.kpi-label {font-size:1.1rem;font-weight:600;margin-bottom:0.3rem;}
.kpi-value {font-size:2.1rem;font-weight:800;}

/* 필터 영역 */
.filter-expander {margin-bottom:1.2rem;}

/* 공통 내보내기 버튼 스타일 */
div.stButton > button {
    background:linear-gradient(90deg,#60a5fa,#818cf8);  /* 기본 파랑톤 */
    color:white;
    border:none;
    padding:0.6rem 1.5rem;
    border-radius:10px;
    font-size:1.1rem;
    font-weight:600;
    box-shadow:0 2px 8px #60a5fa33;
    cursor:pointer;
    transition: all 0.2s ease;
}

/* Excel 버튼 전용 스타일 */
div.stButton > button:has-text("📊 Excel 내보내기"),
div.stButton > button:nth-of-type(2) {
    background:linear-gradient(90deg,#22c55e,#2dd4bf);
}

/* PDF 버튼 전용 스타일 */
div.stButton > button:has-text("📄 PDF 내보내기"),
div.stButton > button:nth-of-type(1) {
    background:linear-gradient(90deg,#3b82f6,#6366f1);
}
</style>
"""