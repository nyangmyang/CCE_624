import streamlit as st

def my_function():
    st.success("Python 함수 실행됨!")

# 버튼 커스터마이징 (st.button에 적용될 CSS)
st.markdown("""
    <style>
    div.stButton > button.custom-btn {
        background-color: #f63366;
        color: white;
        padding: 10px 24px;
        border-radius: 10px;
        border: none;
        font-size: 16px;
    }
    </style>
""", unsafe_allow_html=True)

# 커스텀 클래스가 적용된 st.button
clicked = st.button("실행", key="my_custom_button", help="커스텀 버튼", type="primary")

# 커스텀 클래스 부여 (Streamlit 내부적으로 클래스 이름을 직접 지정할 수는 없지만 HTML 구조는 예측 가능)
# st.button이 만들어낸 HTML 버튼은 자동으로 감싸져 있으므로 해당 구조를 CSS에서 타겟팅하는 것

if clicked:
    my_function()
