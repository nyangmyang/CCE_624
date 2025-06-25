STYLES = """
<style>
body, .stApp {
    background: linear-gradient(135deg, #e0e7ff 0%, #f0fdfa 100%) !important;
    min-height: 100vh;
}

.main-container {
    padding: 2.5rem 2rem 2rem 2rem;
    max-width: 1200px;
    margin: 0 auto;
}

.content-area, .content-area-fixed {
    background: rgba(255,255,255,0.85);
    border-radius: 24px;
    padding: 2.5rem 2rem;
    margin-bottom: 2.5rem;
    height: 500px !important;
    max-height: 500px !important;
    min-height: 500px !important;
    overflow-y: auto !important;
    border: none;
    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.18);
    backdrop-filter: blur(6px);
    width: 100%;
    box-sizing: border-box;
    transition: box-shadow 0.3s;
}

.content-area::-webkit-scrollbar, .content-area-fixed::-webkit-scrollbar {
    width: 7px;
    background: #e0e7ff;
    border-radius: 8px;
}
.content-area::-webkit-scrollbar-thumb, .content-area-fixed::-webkit-scrollbar-thumb {
    background: linear-gradient(135deg, #60a5fa 0%, #818cf8 100%);
    border-radius: 8px;
}

.host-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 2rem;
    width: 100%;
    justify-content: flex-start;
}

.host-card {
    background: rgba(96,165,250,0.15);
    color: #222;
    border-radius: 20px;
    padding: 1.1rem 0.7rem;
    text-align: center;
    min-height: 180px;
    min-width: 150px;
    max-width: 170px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 24px 0 rgba(96,165,250,0.10);
    cursor: pointer;
    transition: transform 0.18s, box-shadow 0.18s;
    margin-bottom: 0.5rem;
    border: 1.5px solid #e0e7ff;
    position: relative;
}
.host-card:hover {
    transform: scale(1.045);
    box-shadow: 0 8px 32px 0 rgba(96,165,250,0.18);
    border: 1.5px solid #60a5fa;
}
.host-card img {
    width: 54px;
    height: 54px;
    margin-bottom: 1rem;
    object-fit: contain;
    filter: drop-shadow(0 2px 8px #60a5fa33);
}
.host-card .host-info {
    line-height: 1.6;
    font-size: 1.08rem;
    font-weight: 500;
}
.host-card .host-info div {
    margin: 4px 0;
    font-size: 15px;
    font-weight: 500;
}

/* 커스텀 체크박스 */
input[type="checkbox"].host-checkbox {
    accent-color: #60a5fa;
    width: 22px;
    height: 22px;
    border-radius: 6px;
    border: 2px solid #818cf8;
    margin-bottom: 0.7rem;
    box-shadow: 0 2px 8px #60a5fa22;
    transition: border 0.2s;
}
input[type="checkbox"].host-checkbox:checked {
    border: 2px solid #60a5fa;
    background: #60a5fa;
}

/* 버튼 */
.stButton > button {
    background: linear-gradient(90deg, #60a5fa 0%, #818cf8 100%);
    color: white;
    border: none;
    padding: 0.7rem 2.2rem;
    border-radius: 12px;
    font-size: 1.1rem;
    font-weight: 600;
    box-shadow: 0 2px 8px #60a5fa33;
    transition: background 0.2s, box-shadow 0.2s, transform 0.15s;
}
.stButton > button:hover {
    background: linear-gradient(90deg, #818cf8 0%, #60a5fa 100%);
    box-shadow: 0 4px 16px #818cf855;
    transform: translateY(-2px) scale(1.03);
}

/* 헤더, 타이틀 */
.stApp h1, .stApp h2, .stApp h3, .stApp h4 {
    font-family: 'Nanum Gothic', 'Pretendard', 'Segoe UI', sans-serif;
    font-weight: 800;
    color: #3730a3;
    letter-spacing: -1px;
}

.stApp h1 {
    font-size: 2.3rem;
    margin-bottom: 1.2rem;
}
.stApp h2 {
    font-size: 1.5rem;
    margin-bottom: 1rem;
}

/* Streamlit 기본 스타일 조정 */
.stCheckbox > label > div[data-testid="stMarkdownContainer"] > p {
    font-size: 1.1rem;
    font-weight: 600;
    color: #3730a3;
}

/* 여백 조정 */
.block-container {
    padding-top: 1.5rem;
    padding-bottom: 1.5rem;
}

/* 실행 버튼 영역 */
.run-button-container {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    z-index: 1000;
}

/* 사이드바 숨기기 */
.css-1d391kg {
    display: none;
}

</style>
"""