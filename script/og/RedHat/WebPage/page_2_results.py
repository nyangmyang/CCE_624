import streamlit as st
import pandas as pd
from Parsing.parsingMain import process_csv_files

def show():
    tab1, tab2 = st.tabs(["📋 점검 결과 목록", "📊 대시보드 요약"])

    with tab1:
        st.header("📋 점검 결과 목록")
        st.write("업로드된 결과 목록")

        file_list = [
            "linux_report_web1.csv",
            "linux_report_web2.csv",
            "linux_report_web3.csv"
        ]

        selected = st.selectbox("결과 파일 선택", file_list)

        if selected:
            st.write(f"선택된 파일: {selected}")
            st.image("https://via.placeholder.com/600x200?text=결과+미리보기", use_column_width=True)

        if st.button("상세 보고서 다운로드"):
            st.info("📄 보고서를 생성 중입니다...")
            try:
                process_csv_files()
                st.success("✅ 보고서 생성이 완료되었습니다!")
            except Exception as e:
                st.error(f"❌ 오류 발생: {e}")

    with tab2:
        st.header("📊 점검 요약 대시보드")
        st.markdown("##### 전체 점검 통계 요약")

        col1, col2, col3 = st.columns(3)
        col1.metric("총 점검 수", "12")
        col2.metric("위험 시스템", "3", "-1")
        col3.metric("평균 점수", "87.5")

        st.line_chart([87, 85, 88, 90])
        st.bar_chart({"취약점 수": [3, 5, 2]})
