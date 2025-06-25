from __future__ import annotations
from typing import List, Dict
import streamlit as st
import streamlit.components.v1 as components

import sys,os

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, ".."))
sys.path.append(PROJECT_ROOT)
from db_host import HostManager



# 샘플 데이터
HOSTS: List[Dict] = [
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/5/5f/Windows_logo_-_2012.svg",
        "ip": "8.8.8.8",
        "port": 2222,
        "desc": "웹서버",
        "importance": "상"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/6/63/CentOS_color_logo.svg",
        "ip": "8.8.8.8",
        "port": 2222,
        "desc": "DB서버",
        "importance": "상"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/5/5f/Windows_logo_-_2012.svg",
        "ip": "1.1.1.1",
        "port": 22,
        "desc": "테스트",
        "importance": "중"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/6/63/CentOS_color_logo.svg",
        "ip": "192.168.0.10",
        "port": 2200,
        "desc": "Demo",
        "importance": "하"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/5/5f/Windows_logo_-_2012.svg",
        "ip": "192.168.1.100",
        "port": 3389,
        "desc": "파일서버",
        "importance": "중"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/6/63/CentOS_color_logo.svg",
        "ip": "10.0.0.5",
        "port": 22,
        "desc": "백업서버",
        "importance": "상"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/5/5f/Windows_logo_-_2012.svg",
        "ip": "172.16.0.50",
        "port": 80,
        "desc": "모니터링",
        "importance": "중"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/6/63/CentOS_color_logo.svg",
        "ip": "172.16.0.51",
        "port": 443,
        "desc": "로그서버",
        "importance": "하"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/6/63/CentOS_color_logo.svg",
        "ip": "172.16.0.51",
        "port": 443,
        "desc": "로그서버",
        "importance": "하"
    },
    {
        "icon": "https://upload.wikimedia.org/wikipedia/commons/6/63/CentOS_color_logo.svg",
        "ip": "172.16.0.51",
        "port": 443,
        "desc": "로그서버",
        "importance": "하"
    }
]

# ──────────────────────────────────────────────────────────────────────────────
def show() -> None:
    # 카드 리스트 및 상단 액션바를 포함한 전체 HTML+CSS+JS
    html = """
    <style>
    body, .stApp {{ background: #f5f7fa !important; }}
    .host-header-bar {{
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 1.2rem 1.5rem 1.2rem 1.5rem;
        background: #fff;
        border-radius: 18px;
        box-shadow: 0 2px 12px 0 rgba(60,72,100,0.07);
        margin-bottom: 1.2rem;
        position: sticky;
        top: 0;
        z-index: 10;
    }}
    .host-header-bar .host-title {{
        font-size: 1.5rem;
        font-weight: 700;
        color: #22223b;
        letter-spacing: -1px;
    }}
    .host-header-bar .host-actions {{
        display: flex;
        align-items: center;
        gap: 1.2rem;
    }}
    .host-header-bar .host-btn {{
        background: linear-gradient(90deg,#2563eb 60%,#60a5fa 100%);
        color: #fff;
        border: none;
        border-radius: 8px;
        padding: 0.5rem 1.2rem;
        font-weight: 600;
        font-size: 1rem;
        cursor: pointer;
        box-shadow: 0 2px 8px 0 rgba(60,72,100,0.07);
        transition: background 0.2s;
    }}
    .host-header-bar .host-btn:hover {{
        background: linear-gradient(90deg,#1d4ed8 60%,#3b82f6 100%);
    }}
    .scrollable-host-section {{
        max-height: 420px;
        overflow-y: auto;
        padding: 0.5rem 0 0.5rem 0;
        border-radius: 18px;
        background: #fff;
        box-shadow: 0 2px 12px 0 rgba(60,72,100,0.07);
        margin-bottom: 1.5rem;
    }}
    .host-grid {{
        display: flex;
        flex-wrap: wrap;
        gap: 1.2rem;
        padding: 1rem;
    }}
    .host-card {{
        background: #f8fafc;
        border-radius: 14px;
        box-shadow: 0 1px 6px 0 rgba(60,72,100,0.06);
        padding: 1.1rem 1.2rem;
        min-width: 260px;
        max-width: 320px;
        flex: 1 1 260px;
        display: flex;
        align-items: flex-start;
        transition: box-shadow 0.18s, transform 0.18s;
        position: relative;
    }}
    .host-card:hover {{
        box-shadow: 0 4px 18px 0 rgba(60,72,100,0.13);
        transform: translateY(-2px) scale(1.02);
    }}
    .host-checkbox {{
        position: absolute;
        left: 1rem;
        top: 1rem;
        width: 1.1rem;
        height: 1.1rem;
        accent-color: #2563eb;
        z-index: 2;
    }}
    .host-card-content {{
        display: flex;
        align-items: center;
        gap: 1.1rem;
        margin-left: 2.2rem;
    }}
    .host-icon {{
        width: 38px;
        height: 38px;
        border-radius: 8px;
        background: #e0e7ef;
        object-fit: contain;
        box-shadow: 0 1px 4px 0 rgba(60,72,100,0.07);
    }}
    .host-info {{
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
    }}
    .host-ip {{
        font-size: 1.08rem;
        font-weight: 600;
        color: #22223b;
        margin-bottom: 0.1rem;
    }}
    .host-desc {{
        font-size: 0.98rem;
        color: #64748b;
        margin-bottom: 0.1rem;
    }}
    .host-meta {{
        margin-top: 0.2rem;
    }}
    .importance {{
        display: inline-block;
        padding: 0.18rem 0.7rem;
        border-radius: 1rem;
        font-size: 0.92rem;
        font-weight: 600;
        background: #e0e7ef;
        color: #2563eb;
        letter-spacing: 0.01em;
    }}
    .importance-상 {{ background: #fee2e2; color: #dc2626; }}
    .importance-중 {{ background: #fef9c3; color: #ca8a04; }}
    .importance-하 {{ background: #d1fae5; color: #059669; }}
    </style>
    <div class="host-header-bar">
        <div class="host-title">대상 호스트</div>
        <div class="host-actions">
            <span style="font-size:1.05rem;color:#64748b;font-weight:600;">
                총 <span style="color:#2563eb">{count}</span>개
            </span>
            <label style="margin-left:1.2rem;">
                <input type="checkbox" id="all_hosts_cb" style="accent-color:#2563eb;transform:scale(1.2);margin-right:0.4rem;" onclick="toggleAllHosts()">
                <span style="font-size:1rem;color:#22223b;">모든 호스트 선택</span>
            </label>
            <button class="host-btn" onclick="alert('호스트 추가 기능은 JS에서 구현 필요!')">호스트 추가</button>
        </div>
    </div>
    <div class='scrollable-host-section'>
        <div class='host-grid'>
    """.format(count=len(HOSTS))

    for i, host in enumerate(HOSTS):
        html += f"""
        <div class='host-card'>
            <input type='checkbox' id='host-{i}' name='host-{i}' class='host-checkbox' data-host-idx='{i}'/>
            <label for='host-{i}'>
                <div class='host-card-content'>
                    <img src='{host["icon"]}' alt='OS Icon' class='host-icon'/>
                    <div class='host-info'>
                        <div class='host-ip'>{host["ip"]}:{host["port"]}</div>
                        <div class='host-desc'>{host["desc"]}</div>
                        <div class='host-meta'>
                            <span class='importance importance-{host["importance"]}'>{host["importance"]}</span>
                        </div>
                    </div>
                </div>
            </label>
        </div>
        """

    html += """
        </div>
    </div>
    <div style="display:flex;justify-content:flex-end;margin-top:2rem;">
        <button class="host-btn" style="font-size:1.1rem;padding:0.7rem 2.2rem;" onclick="scanSelectedHosts()">
            🛠️ 선택 호스트 점검
        </button>
    </div>
    <script>
    function toggleAllHosts() {
        const allChecked = document.getElementById('all_hosts_cb').checked;
        document.querySelectorAll('.host-checkbox').forEach(cb => {
            cb.checked = allChecked;
        });
    }
    function scanSelectedHosts() {
        const selected = [];
        document.querySelectorAll('.host-checkbox').forEach(cb => {
            if (cb.checked) selected.push(parseInt(cb.dataset.hostIdx));
        });
        alert('선택된 호스트 인덱스: ' + JSON.stringify(selected));
        // 실제 서비스에서는 이 데이터를 서버로 전송하거나, Streamlit에 postMessage 등으로 전달 가능
    }
    </script>
    """

    components.html(html, height=800, scrolling=True)

    if st.button("🛠️ 선택 호스트 점검", use_container_width=True):
        # For test purpose
        # selected_hosts = get_selected_hosts()
        selected_hosts = st.session_state.hosts

      
if __name__ == "__main__":
    show()
