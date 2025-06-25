# from __future__ import annotations

# import importlib
# from functools import lru_cache
# from types import ModuleType
# from typing import Dict

# import streamlit as st

# # ──────────────────────────────────────────────────────────────────────────────
# # 기본 설정
# # ──────────────────────────────────────────────────────────────────────────────
# st.set_page_config(
#     page_title="보안 점검 시스템",
#     page_icon="🛡️",
#     layout="wide",
#     initial_sidebar_state="expanded",
# )

# # 페이지 ↔ 모듈 매핑 -----------------------------------------------------------
# PAGES: Dict[str, str] = {
#     "🏠 메인페이지":       "WebPage.page_1_main_page",
#     "✅ 점검":             "WebPage.page_5_scanpage",
#     "📋 진단 결과 분석":   "WebPage.page_3_diagnosis_result",
#     "📈 대시보드":         "WebPage.page_4_dash_board",   # ← 대시보드 모듈
# }

# CAPTIONS: Dict[str, str] = {
#     "🏠 메인페이지":       "시스템 개요 및 안내 페이지입니다.",
#     "✅ 점검":             "선택 서버에 대해 실시간 보안 점검을 수행합니다.",
#     "📋 진단 결과 분석":   "전체 진단 결과를 테이블로 확인하고 조치 방법을 검토합니다.",
#     "📈 대시보드":         "KPI·차트로 전체 보안 상태를 한눈에 파악합니다.",
# }

# # 최초 진입 시 기본 페이지
# if "current_page" not in st.session_state:
#     st.session_state.current_page = next(iter(PAGES))  # 첫 항목(🏠 메인페이지)

# @lru_cache(maxsize=None)
# def _import_page(module_path: str) -> ModuleType:
#     """동적 import + 캐싱"""
#     return importlib.import_module(module_path)

# # ──────────────────────────────────────────────────────────────────────────────
# # 사이드바 UI
# # ──────────────────────────────────────────────────────────────────────────────
# st.sidebar.title("🛡️ 보안 점검 시스템")
# st.sidebar.markdown("---")

# page_selection = st.sidebar.radio(
#     "🧭 **페이지 이동**",
#     list(PAGES.keys()),
#     index=list(PAGES.keys()).index(st.session_state.current_page),
#     key="current_page",   # widget ↔ session_state 동기화
# )

# st.sidebar.caption(CAPTIONS[page_selection])
# st.sidebar.markdown("---")
# st.sidebar.metric("연결 상태", "🟢 정상")
# st.sidebar.caption("© 2025 보안 점검 시스템 v1.0.0")

# # ──────────────────────────────────────────────────────────────────────────────
# # 페이지 렌더
# # ──────────────────────────────────────────────────────────────────────────────
# try:
#     _import_page(PAGES[page_selection]).show()
# except Exception as err:          # pragma: no cover
#     st.exception(err)
#     st.info("🔄 새로고침 후 다시 시도해 주세요.")



### 8502 페이지를 렌더링하는 방식의 챗봇 구현 ###
from __future__ import annotations

import importlib
from functools import lru_cache
from types import ModuleType
from typing import Dict

import streamlit as st

# ──────────────────────────────────────────────────────────────────────────────
# 기본 설정
# ──────────────────────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="보안 점검 시스템",
    page_icon="🛡️",
    layout="wide",
    initial_sidebar_state="expanded",
)

# 페이지 ↔ 모듈 매핑 -----------------------------------------------------------
PAGES: Dict[str, str] = {
    "🏠 메인페이지":       "WebPage.page_1_main_page",
    "✅ 점검":             "WebPage.page_5_scanpage",
    "📋 진단 결과 분석":   "WebPage.page_3_diagnosis_result",
    "📈 대시보드":         "WebPage.page_4_dash_board",
}

CAPTIONS: Dict[str, str] = {
    "🏠 메인페이지":       "시스템 개요 및 안내 페이지입니다.",
    "✅ 점검":             "선택 서버에 대해 실시간 보안 점검을 수행합니다.",
    "📋 진단 결과 분석":   "전체 진단 결과를 테이블로 확인하고 조치 방법을 검토합니다.",
    "📈 대시보드":         "KPI·차트로 전체 보안 상태를 한눈에 파악합니다.",
}

# 최초 진입 시 기본 페이지
if "current_page" not in st.session_state:
    st.session_state.current_page = next(iter(PAGES))

# 만약 세션 상태에 chatbot_visible이란 값이 없다면, 그 값을 False로 설정
if "chatbot_visible" not in st.session_state:
    st.session_state.chatbot_visible = False

@lru_cache(maxsize=None)
def _import_page(module_path: str) -> ModuleType:
    """동적 import + 캐싱"""
    return importlib.import_module(module_path)

# ──────────────────────────────────────────────────────────────────────────────
# 사이드바 UI
# ──────────────────────────────────────────────────────────────────────────────
st.sidebar.title("🛡️ 보안 점검 시스템")
st.sidebar.markdown("---")

page_selection = st.sidebar.radio(
    "🧭 **페이지 이동**",
    list(PAGES.keys()),
    index=list(PAGES.keys()).index(st.session_state.current_page),
    key="current_page",
)

st.sidebar.caption(CAPTIONS[page_selection])
st.sidebar.markdown("---")
st.sidebar.metric("연결 상태", "🟢 정상")

# 챗봇 열기 버튼 (버튼 클릭 시 토글)
if st.sidebar.button("🤖 챗봇 열기 / 닫기"):
    st.session_state.chatbot_visible = not st.session_state.chatbot_visible

st.sidebar.caption("© 2025 보안 점검 시스템 v1.0.0")

# ──────────────────────────────────────────────────────────────────────────────
# 페이지 렌더
# ──────────────────────────────────────────────────────────────────────────────
try:
    _import_page(PAGES[page_selection]).show()
except Exception as err:
    st.exception(err)
    st.info("🔄 새로고침 후 다시 시도해 주세요.")

# ──────────────────────────────────────────────────────────────────────────────
# 챗봇 iframe 렌더링 (옵션)
# ──────────────────────────────────────────────────────────────────────────────
if st.session_state.chatbot_visible:
    st.markdown("""
        <style>
        .chat-iframe {
            position: fixed;
            bottom: 80px;
            right: 30px;
            width: 480px;  /* 💡 더 넓게 */
            height: 550px; /* 💡 더 높게 */
            border: none;
            border-radius: 16px;
            box-shadow: 0 6px 16px rgba(0,0,0,0.2);
            z-index: 1000;
        }
        </style>
        <iframe class="chat-iframe" src="http://localhost:8502"></iframe>
    """, unsafe_allow_html=True)


#####################################################################
### WebPage.chatbot_widget.py 로 모듈화해서 사용하는 방법 ###
# from __future__ import annotations

# import importlib
# from functools import lru_cache
# from types import ModuleType
# from typing import Dict

# import streamlit as st
# from langchain_openai import ChatOpenAI
# from langchain_core.messages import HumanMessage, AIMessage
# from langchain.prompts import ChatPromptTemplate
# from dotenv import load_dotenv

# # ──────────────────────────────────────────────────────────────────────────────
# # 기본 설정
# # ──────────────────────────────────────────────────────────────────────────────
# st.set_page_config(
#     page_title="보안 점검 시스템",
#     page_icon="🛡️",
#     layout="wide",
#     initial_sidebar_state="expanded",
# )

# # 환경 변수 로드
# load_dotenv()

# # GPT 모델 설정
# llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.4)

# # 시스템 프롬프트 구성
# chat_prompt = ChatPromptTemplate.from_messages([
#     ("system", 
#      "너는 리눅스, 윈도우 서버 보안 및 인프라 자동화 전문가야. "
#      "CCE 기반 취약점 진단, Ansible을 활용한 서버 보안 점검 자동화, "
#      "OS별 패키지 관리, SSH 설정, 시스템 로그 분석, 네트워크 포트 점검 등에 대한 "
#      "기술적인 질문에 정확하고 명확하게 답해줘."),
#     ("user", "{question}")
# ])
# chat_chain = chat_prompt | llm

# # ──────────────────────────────────────────────────────────────────────────────
# # 세션 상태 초기화
# # ──────────────────────────────────────────────────────────────────────────────
# if "current_page" not in st.session_state:
#     st.session_state.current_page = "🏠 메인페이지"
# if "chatbot_visible" not in st.session_state:
#     st.session_state.chatbot_visible = False
# if "messages" not in st.session_state:
#     st.session_state.messages = []

# # ──────────────────────────────────────────────────────────────────────────────
# # 페이지 ↔ 모듈 매핑
# # ──────────────────────────────────────────────────────────────────────────────
# PAGES: Dict[str, str] = {
#     "🏠 메인페이지":       "WebPage.page_1_main_page",
#     "✅ 점검":             "WebPage.page_5_scanpage",
#     "📋 진단 결과 분석":   "WebPage.page_3_diagnosis_result",
#     "📈 대시보드":         "WebPage.page_4_dash_board",
# }

# CAPTIONS: Dict[str, str] = {
#     "🏠 메인페이지":       "시스템 개요 및 안내 페이지입니다.",
#     "✅ 점검":             "선택 서버에 대해 실시간 보안 점검을 수행합니다.",
#     "📋 진단 결과 분석":   "전체 진단 결과를 테이블로 확인하고 조치 방법을 검토합니다.",
#     "📈 대시보드":         "KPI·차트로 전체 보안 상태를 한눈에 파악합니다.",
# }

# @lru_cache(maxsize=None)
# def _import_page(module_path: str) -> ModuleType:
#     return importlib.import_module(module_path)

# # ──────────────────────────────────────────────────────────────────────────────
# # 사이드바
# # ──────────────────────────────────────────────────────────────────────────────
# st.sidebar.title("🛡️ 보안 점검 시스템")
# st.sidebar.markdown("---")

# page_selection = st.sidebar.radio(
#     "🧭 **페이지 이동**",
#     list(PAGES.keys()),
#     index=list(PAGES.keys()).index(st.session_state.current_page),
#     key="current_page",
# )

# st.sidebar.caption(CAPTIONS[page_selection])
# st.sidebar.markdown("---")
# st.sidebar.metric("연결 상태", "🟢 정상")

# # 챗봇 열기/닫기 토글 버튼
# if st.sidebar.button("🤖 챗봇 열기 / 닫기"):
#     st.session_state.chatbot_visible = not st.session_state.chatbot_visible

# st.sidebar.caption("© 2025 보안 점검 시스템 v1.0.0")

# # ──────────────────────────────────────────────────────────────────────────────
# # 페이지 렌더링
# # ──────────────────────────────────────────────────────────────────────────────
# try:
#     _import_page(PAGES[page_selection]).show()
# except Exception as err:
#     st.exception(err)
#     st.info("🔄 새로고침 후 다시 시도해 주세요.")

# # ──────────────────────────────────────────────────────────────────────────────
# # 챗봇 모달 형태로 내부 렌더링
# # ──────────────────────────────────────────────────────────────────────────────
# if st.session_state.chatbot_visible:
#     st.markdown("""
#         <style>
#         .chatbox-style {
#             border: 1px solid #ccc;
#             border-radius: 12px;
#             padding: 16px;
#             background-color: #f9f9f9;
#             box-shadow: 0 4px 8px rgba(0,0,0,0.1);
#             margin-top: 20px;
#         }
#         .chat-message p {
#             font-size: 14px !important;
#             line-height: 1.6 !important;
#             margin-bottom: 10px;
#         }
#         </style>
#     """, unsafe_allow_html=True)

#     with st.expander("🤖 보안 자동화 챗봇", expanded=True):
#         with st.container():
#             for msg in st.session_state.messages:
#                 if isinstance(msg, HumanMessage):
#                     with st.chat_message("user"):
#                         st.markdown(msg.content)
#                 elif isinstance(msg, AIMessage):
#                     with st.chat_message("assistant"):
#                         st.markdown(msg.content)

#             user_input = st.chat_input("보안 관련 질문을 입력하세요.")
#             if user_input:
#                 st.session_state.messages.append(HumanMessage(content=user_input))
#                 with st.chat_message("user"):
#                     st.markdown(user_input)

#                 with st.spinner("답변 생성 중..."):
#                     try:
#                         response = chat_chain.invoke({"question": user_input})
#                         answer = response.content
#                     except Exception as e:
#                         answer = f"❌ 오류 발생: {e}"

#                 st.session_state.messages.append(AIMessage(content=answer))
#                 with st.chat_message("assistant"):
#                     st.markdown(answer)
#####################################################################