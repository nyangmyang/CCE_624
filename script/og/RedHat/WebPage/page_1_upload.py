import streamlit as st

def show():
    st.title("📁 점검 파일 업로드")
    
    uploaded_file = st.file_uploader("파일 업로드", type=["ini"])
    if uploaded_file:
        st.success(f"{uploaded_file.name} 업로드 완료")
