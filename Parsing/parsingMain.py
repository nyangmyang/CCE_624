import os
import glob
import json
import shutil
from openpyxl import load_workbook

from .csvParsing import make_excel_report
from .makechart import create_chart, make_col_chart
from .runMecro import run_macro

script_dir = os.path.dirname(os.path.abspath(__file__))

def truncate_title(title, limit=28):
    return title[:limit]

def process_json_files():
    json_files = glob.glob('result/*.json')
    print(json_files)
    print("점검 시스템 개수:", len(json_files))

    # ✅ 원본 xlsm 파일
    base_excel_file = os.path.join(script_dir, "취약점 진단 상세 보고서_0603.xlsm")

    # ✅ 복사본 xlsm 파일 (매크로 실행용)
    copied_excel_file = os.path.join(script_dir, "temp_macro_workbook.xlsm")

    # ✅ 결과 파일 (xlsx)
    result_file = '취약점 진단 상세 보고서_result.xlsx'

    # ✅ 기존 복사본 있으면 삭제 후 복사
    if os.path.exists(copied_excel_file):
        os.remove(copied_excel_file)
    shutil.copy(base_excel_file, copied_excel_file)

    # ✅ 복사된 xlsm 파일에 대해 매크로 실행
    run_macro(copied_excel_file, len(json_files) - 1)

    # ✅ 복사본 파일 로드
    excel = load_workbook(copied_excel_file)

    sheet_num = 1
    stats_column = 'L'

    def next_column(col):
        if col[-1] == 'Z':
            return col[:-1] + 'A' + 'A' if col[:-1] == '' else chr(ord(col[:-1]) + 1) + 'A'
        else:
            return col[:-1] + chr(ord(col[-1]) + 1)

    for json_file in json_files:
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        ip = data["targetip"]
        os_info = data["osinfo"]
        name = os.path.splitext(os.path.basename(json_file))[0]
        result_list = data["result"]

        inspection_result, detail, solution = [], [], []

        for item in result_list:
            result = item["result"]
            inspection_result.append(
                "양호" if result == 0 else
                "취약" if result == 1 else
                "N/A" if result == 2 else "인터뷰"
            )
            detail.append(item["codedetail"])
            solution.append(item["resultdetail"])

        system_result = excel["시스템 별 점검 결과"]

        if hasattr(system_result, "_charts"):
            system_result._charts.clear()

        sheet_title = f"시스템결과_{truncate_title(name)}"
        system_copied = excel.copy_worksheet(system_result)
        system_copied.title = sheet_title

        create_chart(system_copied)

        make_excel_report(
            system_num=sheet_num,
            excel=excel,
            result_path=result_file,
            system_copied=system_copied,
            inspection_result=inspection_result,
            detail=detail,
            solution=solution,
            stats_column=stats_column,
            ip=ip,
            os=os_info,
            name=name,
            all_system=len(json_files)
        )

        print(f"{sheet_num}_번 시스템 결과 생성 완료")
        stats_column = next_column(stats_column)
        sheet_num += 1

    make_col_chart(len(json_files), excel["요약 통계"], "V6", excel["보안 수준 통계"])
    make_col_chart(len(json_files), excel["요약 통계"], "H27", excel["요약 통계"])

    excel.save(result_file)
    print("모든 시스템 결과 생성 완료")

    # # ✅ 임시 복사본 삭제
    # if os.path.exists(copied_excel_file):
    #     os.remove(copied_excel_file)

    return result_file
