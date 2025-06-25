"""
원본 데이터 (df)
    ↓
사이드바 필터 UI (create_sidebar_filters)
    ↓
필터 조건 수집 (filters)
    ↓  
데이터 필터링 (apply_filters)
    ↓
필터링된 데이터 (filtered_df)
    ↓
기존 모든 함수들에 전달 (calc_kpi, create_dashboard_charts_section...)
"""
"""filters.py - 필터링 기능 모듈

* 2025-06-23 • 필터링 기능 추가
* 기능:
    - 사이드바 필터 UI 생성
    - 데이터 필터링 로직
    - 필터 상태 표시 및 초기화
"""

from typing import Dict, List, Any
import pandas as pd
import streamlit as st


def create_sidebar_filters(df: pd.DataFrame) -> Dict[str, Any]:
    """
    사이드바에 필터 UI를 생성하고 사용자 선택값을 반환
    
    Args:
        df: 원본 데이터프레임
        
    Returns:
        dict: 필터 조건들 {"pcs": [...], "risk": "상", "results": [...]}
    """
    
    # 사이드바 헤더
    st.sidebar.markdown(" ## 🔍 필터 설정")
    st.sidebar.markdown("---")
    
    
    # ========================================================================
    # 1. PC 선택 필터 (멀티셀렉트)
    # ========================================================================
    all_pcs = sorted(df["PC명"].unique().tolist())
    selected_pcs = st.sidebar.multiselect(
        "📟 PC 선택",
        options=all_pcs,
        default=all_pcs,
        help=f"전체 {len(all_pcs)}개 PC 중에서 선택"
    )
    
    # ========================================================================
    # 2. 위험도 필터 (단일 선택)
    # ========================================================================
    available_risks = sorted(df["위험도"].unique().tolist())
    risk_options = ["전체"] + available_risks
    
    selected_risk = st.sidebar.selectbox(
        "⚠️ 위험도",
        options=risk_options,
        index=0,
        help="위험도별 필터링 (전체 선택 시 모든 위험도 포함)"
    )
    
    # ========================================================================
    # 3. 확인결과 필터 (멀티셀렉트)
    # ========================================================================
    all_results = sorted(df["확인결과"].unique().tolist())
    selected_results = st.sidebar.multiselect(
        "✅ 확인결과",
        options=all_results,
        default=all_results,
        help=f"확인결과별 필터링 ({', '.join(all_results)})"
    )
    
    # ========================================================================
    # 4. 추가 필터들 (카테고리가 있다면)
    # ========================================================================
    selected_categories = None
    if "카테고리" in df.columns:
        all_categories = sorted(df["카테고리"].unique().tolist())
        selected_categories = st.sidebar.multiselect(
            "📂 카테고리",
            options=all_categories,
            default=all_categories,
            help="보안 점검 카테고리별 필터링"
        )
    
    # ========================================================================
    # 5. 필터 상태 표시
    # ========================================================================
    st.sidebar.markdown("---")
    st.sidebar.markdown("### 📊 필터 상태")
    
    # 선택된 항목 수 표시
    st.sidebar.info(f"**PC:** {len(selected_pcs)}/{len(all_pcs)}개 선택")
    st.sidebar.info(f"**위험도:** {selected_risk}")
    st.sidebar.info(f"**결과:** {len(selected_results)}/{len(all_results)}개 선택")
    
    if selected_categories is not None:
        st.sidebar.info(f"**카테고리:** {len(selected_categories)}개 선택")
    
    # ========================================================================
    # 6. 필터 초기화 버튼
    # ========================================================================
    st.sidebar.markdown("---")
    col1, col2 = st.sidebar.columns(2)
    
    with col1:
        if st.button("🔄 초기화", use_container_width=True):
            st.experimental_rerun()
    
    with col2:
        # 현재 필터 적용 결과 미리보기
        temp_filters = {
            "pcs": selected_pcs,
            "risk": selected_risk,
            "results": selected_results,
            "categories": selected_categories
        }
        filtered_count = len(apply_filters(df, temp_filters))
        st.metric("필터 결과", f"{filtered_count}건")
    
    # ========================================================================
    # 7. 필터 조건 반환
    # ========================================================================
    return {
        "pcs": selected_pcs,
        "risk": selected_risk,
        "results": selected_results,
        "categories": selected_categories
    }


def apply_filters(df: pd.DataFrame, filters: Dict[str, Any]) -> pd.DataFrame:
    """
    필터 조건에 따라 데이터프레임을 필터링
    
    Args:
        df: 원본 데이터프레임
        filters: create_sidebar_filters()에서 반환된 필터 조건
        
    Returns:
        pd.DataFrame: 필터링된 데이터프레임
    """
    
    # 원본 데이터 복사 (원본 보존)
    filtered_df = df.copy()
    
    # ========================================================================
    # 1. PC 필터 적용
    # ========================================================================
    if filters["pcs"]:  # 선택된 PC가 있으면
        filtered_df = filtered_df[filtered_df["PC명"].isin(filters["pcs"])]
    else:
        # PC를 하나도 선택하지 않은 경우 빈 데이터프레임 반환
        return pd.DataFrame()
    
    # ========================================================================
    # 2. 위험도 필터 적용
    # ========================================================================
    if filters["risk"] != "전체":
        filtered_df = filtered_df[filtered_df["위험도"] == filters["risk"]]
    
    # ========================================================================
    # 3. 확인결과 필터 적용
    # ========================================================================
    if filters["results"]:  # 선택된 결과가 있으면
        filtered_df = filtered_df[filtered_df["확인결과"].isin(filters["results"])]
    else:
        # 결과를 하나도 선택하지 않은 경우 빈 데이터프레임 반환
        return pd.DataFrame()
    
    # ========================================================================
    # 4. 카테고리 필터 적용 (있는 경우)
    # ========================================================================
    if filters["categories"] is not None and "카테고리" in df.columns:
        if filters["categories"]:  # 선택된 카테고리가 있으면
            filtered_df = filtered_df[filtered_df["카테고리"].isin(filters["categories"])]
        else:
            # 카테고리를 하나도 선택하지 않은 경우 빈 데이터프레임 반환
            return pd.DataFrame()
    
    return filtered_df


def show_filter_summary(original_df: pd.DataFrame, filtered_df: pd.DataFrame) -> None:
    """
    필터링 결과 요약을 표시
    
    Args:
        original_df: 원본 데이터프레임
        filtered_df: 필터링된 데이터프레임
    """
    
    original_count = len(original_df)
    filtered_count = len(filtered_df)
    filter_ratio = (filtered_count / original_count * 100) if original_count > 0 else 0
    
    # 필터링 결과 요약 표시
    if filtered_count == 0:
        st.warning("⚠️ 선택한 조건에 맞는 데이터가 없습니다. 필터 조건을 확인해주세요.")
        return
    
    if filtered_count < original_count:
        st.info(
            f"🔍 **필터 적용됨:** 전체 {original_count:,}건 중 {filtered_count:,}건 표시 "
            f"({filter_ratio:.1f}%)"
        )
    
    # 필터링으로 제외된 데이터가 많은 경우 경고
    if filter_ratio < 10:
        st.warning(
            f"⚠️ 필터 조건이 너무 엄격합니다. 전체 데이터의 {filter_ratio:.1f}%만 표시되고 있습니다."
        )


def get_filter_description(filters: Dict[str, Any]) -> str:
    """
    현재 적용된 필터 조건을 문자열로 반환
    
    Args:
        filters: 필터 조건 딕셔너리
        
    Returns:
        str: 필터 조건 설명 문자열
    """
    
    descriptions = []
    
    # PC 필터 설명
    if filters["pcs"]:
        if len(filters["pcs"]) == 1:
            descriptions.append(f"PC: {filters['pcs'][0]}")
        else:
            descriptions.append(f"PC: {len(filters['pcs'])}개 선택")
    
    # 위험도 필터 설명
    if filters["risk"] != "전체":
        descriptions.append(f"위험도: {filters['risk']}")
    
    # 결과 필터 설명
    if filters["results"]:
        if len(filters["results"]) == 1:
            descriptions.append(f"결과: {filters['results'][0]}")
        else:
            descriptions.append(f"결과: {len(filters['results'])}개 선택")
    
    # 카테고리 필터 설명
    if filters["categories"] is not None and filters["categories"]:
        if len(filters["categories"]) == 1:
            descriptions.append(f"카테고리: {filters['categories'][0]}")
        else:
            descriptions.append(f"카테고리: {len(filters['categories'])}개 선택")
    
    return " | ".join(descriptions) if descriptions else "필터 없음"


# ============================================================================
# 테스트용 함수 (개발 시에만 사용)
# ============================================================================

def test_filters():
    """필터 기능 테스트 (개발용)"""
    
    # 샘플 데이터 생성
    import numpy as np
    
    sample_data = {
        "PC명": np.random.choice(["PC-001", "PC-002", "PC-003"], 100),
        "위험도": np.random.choice(["높음", "중간", "낮음"], 100),
        "확인결과": np.random.choice(["양호", "취약", "수동"], 100),
        "카테고리": np.random.choice(["시스템", "네트워크", "DB"], 100)
    }
    
    df = pd.DataFrame(sample_data)
    
    st.write("### 필터 테스트")
    st.write("원본 데이터:")
    st.dataframe(df.head())
    
    # 필터 적용
    filters = create_sidebar_filters(df)
    filtered_df = apply_filters(df, filters)
    
    st.write("필터링된 데이터:")
    st.dataframe(filtered_df.head())
    
    # 필터 요약 표시
    show_filter_summary(df, filtered_df)
    
    # 필터 설명
    st.write(f"**적용된 필터:** {get_filter_description(filters)}")


if __name__ == "__main__":
    # 테스트 실행
    test_filters()