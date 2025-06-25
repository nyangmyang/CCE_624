import streamlit as st
from dotenv import load_dotenv
import os
from datetime import datetime

from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage
from langchain.prompts import ChatPromptTemplate
from langchain_community.tools.tavily_search import TavilySearchResults

# 📌 환경 변수 로드
load_dotenv()

# 🔍 Tavily 웹 검색 도구 준비
search_tool = TavilySearchResults()

# 💬 GPT 모델 설정 (GPT-4o + 스트리밍 응답)
llm = ChatOpenAI(model="gpt-4o", temperature=0.4, streaming=True)

# 🎯 프롬프트 템플릿 정의
chat_prompt = ChatPromptTemplate.from_messages([
    ("system",
     "너는 리눅스, 윈도우 서버 보안 및 인프라 자동화 전문가야. "
     "사용자의 질문과 최신 검색 결과를 바탕으로 정확하고 현실적인 답변을 제공해줘."),
    ("user", "{question}")
])

# 🔗 체인 생성
chain = chat_prompt | llm

# 🛠️ Streamlit 페이지 구성
st.set_page_config(page_title="보안 자동화 실시간 챗봇", page_icon="🛡️", layout="centered")

# 💬 채팅 메시지 스타일
st.markdown("""
<style>
.chat-message p {
    font-size: 14px !important;
    line-height: 1.6 !important;
    margin-bottom: 10px;
}
</style>
""", unsafe_allow_html=True)

# 🧠 세션 상태 초기화
if "messages" not in st.session_state:
    st.session_state.messages = []

# 📌 타이틀
st.title("🛡️ 보안 자동화 AI 챗봇 (실시간 검색 + 스트리밍)")
st.write("Ubuntu, CentOS, Windows Server 기반 보안 점검 및 Ansible 자동화 관련 질문을 자유롭게 하세요.")

# 🔁 이전 메시지 출력
for msg in st.session_state.messages:
    if isinstance(msg, HumanMessage):
        with st.chat_message("user"):
            st.markdown(msg.content)
    elif isinstance(msg, AIMessage):
        with st.chat_message("assistant"):
            st.markdown(msg.content)

# 📥 사용자 입력 처리
user_input = st.chat_input("보안 관련 궁금한 점을 물어보세요.")
if user_input:
    st.session_state.messages.append(HumanMessage(content=user_input))
    with st.chat_message("user"):
        st.markdown(user_input)

    with st.spinner("실시간 검색 및 답변 생성 중..."):

        try:
            # 📅 오늘 날짜 추가
            today = datetime.now().strftime("%Y-%m-%d")

            # 🔍 Tavily를 통해 실시간 검색 수행
            search_results = search_tool.run(user_input)

            # 🧠 GPT 프롬프트 구성
            prompt_with_context = (
                f"오늘 날짜는 {today}야.\n\n"
                f"사용자의 질문: {user_input}\n\n"
                f"관련 웹 검색 결과:\n{search_results}\n\n"
                f"이 정보를 참고해서 정확하고 신중하게 답변해줘."
            )

            # 🧠 실시간 스트리밍 응답 처리
            full_response = ""
            with st.chat_message("assistant"):
                stream_placeholder = st.empty()

                for chunk in chain.stream({"question": prompt_with_context}):
                    full_response += chunk.content
                    stream_placeholder.markdown(full_response)

        except Exception as e:
            full_response = f"❌ 오류 발생: {e}"
            with st.chat_message("assistant"):
                st.markdown(full_response)

    st.session_state.messages.append(AIMessage(content=full_response))
