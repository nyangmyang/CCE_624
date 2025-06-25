import streamlit as st
from WebPage import page_1_upload, page_2_results

PAGES = {
    "📁 파일 업로드 + 서버 점검": page_1_upload.show,
    "📊 점검 결과 보기": page_2_results.show,
}

st.sidebar.title("🔍 메뉴")
selection = st.sidebar.radio("이동할 페이지 선택", list(PAGES.keys()))
PAGES[selection]()
