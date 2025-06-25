@echo off
start cmd /k "streamlit run Chatbot/Chatbot_app.py --server.port 8502 --server.headless true"
start cmd /k "streamlit run app_chatbot.py"