from dotenv import load_dotenv
load_dotenv()

import os
import streamlit as st
import streamlit.components.v1 as components
import pandas as pd
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage
from langchain.prompts import ChatPromptTemplate

# OpenAI API 키 확인
if os.getenv("OPENAI_API_KEY"):
    print("✅ OpenAI API Key loaded!")

# LangChain LLM 설정
chat_prompt = ChatPromptTemplate.from_messages([
    ("system", "너는 보안 전문가야. CCE 취약점, Ansible 자동화, 리눅스 서버 점검 등에 대해 전문적으로 설명해줘."),
    ("user", "{question}")
])
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.4)
chain = chat_prompt | llm

# 페이지 설정
st.set_page_config(page_title="🔐 보안 점검 대시보드", page_icon="🛡️", layout="wide")

# 서버 목록 예시
server_data = {
    "운영체제": ["Ubuntu Server", "CentOS 7", "Windows Server 2022"],
    "IP 주소": ["192.168.0.10", "192.168.0.20", "192.168.0.30"],
    "CCE 점검 상태": ["양호", "취약", "점검 중"]
}
df_servers = pd.DataFrame(server_data)

# 레이아웃 구성
col_main, col_spacer = st.columns([4, 1])

with col_main:
    st.title("🛡️ 서버 보안 점검 대시보드")
    st.markdown("Ansible을 통한 자동화된 CCE 취약점 점검 결과입니다.")
    st.dataframe(df_servers, use_container_width=True)

# 챗봇 버튼 및 모달
components.html("""
<style>
.chat-button {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background-color: #6c63ff;
    color: white;
    font-size: 28px;
    border: none;
    cursor: pointer;
    z-index: 9999;
}
.chat-modal {
    position: fixed;
    bottom: 90px;
    right: 20px;
    width: 360px;
    height: 500px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    z-index: 10000;
    display: none;
}
.chat-modal iframe {
    width: 100%;
    height: 100%;
    border: none;
    border-radius: 12px;
}
</style>

<button class="chat-button" onclick="toggleModal()">🤖</button>
<div id="chatModal" class="chat-modal">
    <iframe src="http://localhost:8502"></iframe>
</div>

<script>
function toggleModal() {
    const modal = document.getElementById('chatModal');
    if (modal.style.display === 'none' || modal.style.display === '') {
        modal.style.display = 'block';
    } else {
        modal.style.display = 'none';
    }
}
</script>
""", height=600)
