#!/usr/bin/env python3
"""批量将 python3env/miniconda3 的 Scoop 配置迁移到 uv 包管理。"""

import json
import os
import re

BUCKET_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "bucket")


def fix_suggest(data):
    """将 suggest 中的 python: miniconda3 改为 python: uv"""
    suggest = data.get("suggest")
    if isinstance(suggest, dict) and "python" in suggest:
        suggest["python"] = "uv"


def fix_pre_install(data):
    """
    处理 pre_install:
    1. 移除 @call activate python3env / @call conda activate python3env
    2. @python -> @uv run python
    3. @pip install -> @uv pip install
    """
    pre = data.get("pre_install")
    if not pre:
        return
    if isinstance(pre, str):
        pre = [pre]

    new_pre = []
    for line in pre:
        # 移除嵌入在字符串中的 activate 行（单行 Set-Content 格式，\n 分隔）
        line = re.sub(r'\n@call (conda )?activate python3env', '', line)
        line = re.sub(r"@call (conda )?activate python3env\n", '', line)
        # 移除逗号分隔格式中的 activate 部分（e0e1-wx 等）
        line = re.sub(r"',\s*'@call (conda )?activate python3env'", "'", line)
        # 移除独立的 conda activate 行（githacker post_install 用，但这里做通用处理）
        if re.match(r'^\s*"?\s*conda activate python3env\s*"?,?\s*$', line):
            continue
        # 移除纯 @call activate 行（数组格式中的独立元素）
        if re.match(r'^"?@call (conda )?activate python3env"?,?\s*$', line):
            continue

        # @python -> @uv run python
        line = re.sub(r'@python\b', '@uv run python', line)
        # @pip install -> @uv pip install
        line = re.sub(r'@pip install\b', '@uv pip install', line)

        if line.strip():
            new_pre.append(line)

    if not new_pre:
        del data["pre_install"]
    else:
        data["pre_install"] = new_pre[0] if len(new_pre) == 1 else new_pre


def _replace_bat_commands(line):
    """对 .bat 脚本字符串中的命令做替换（适用于 Set-Content 内容）"""
    line = re.sub(r'\n@call (conda )?activate python3env', '', line)
    line = re.sub(r"@call (conda )?activate python3env\n", '', line)
    line = re.sub(r"',\s*'@call (conda )?activate python3env'", "'", line)
    line = re.sub(r'@python\b', '@uv run python', line)
    line = re.sub(r'@pip install\b', '@uv pip install', line)
    return line


def fix_post_install(data):
    """
    处理 post_install 中的 pip install 命令，转换为 uv

    转换规则:
    & cmd /c "call activate python3env && pip install -r $dir\requirements.txt"
    → uv venv "$dir\venv"  +  uv pip install -r "$dir\requirements.txt" --python "$dir\venv\Scripts\python.exe"

    & cmd /c "call activate python3env && pip install <packages>"
    → uv venv "$dir\venv"  +  uv pip install <packages> --python "$dir\venv\Scripts\python.exe"
    """
    post = data.get("post_install")
    if not post:
        return
    if isinstance(post, str):
        post = [post]

    new_post = []
    for line in post:
        # Set-Content 行：对其中的 bat 命令做替换
        if 'Set-Content' in line:
            line = _replace_bat_commands(line)
            new_post.append(line)
            continue

        # 处理 post_install 中直接出现的 @call activate / @python 命令（如 houndsploit）
        line = _replace_bat_commands(line)
        # 清除纯 @call activate 行
        if re.match(r'^"?@call (conda )?activate python3env"?,?\s*$', line):
            continue
        if re.match(r'^"?conda activate python3env"?,?\s*$', line):
            continue

        # 保留 conda if/else 控制流结构行
        if re.search(r'(Get-Command conda|^\s*"\s*\}\s*else\s*\{|^\s*"\s*\}\s*$|^\s*"\s*if\s*\()', line):
            new_post.append(line)
            continue

        # 跳过 conda activate 行
        if re.match(r'^\s*"?\s*conda activate python3env\s*"?,?\s*$', line):
            continue

        # 匹配 & cmd /c "call activate python3env && pip install ..."
        m = re.search(r'"call activate python3env && (pip install .+?)"\s*(,?)\s*$', line)
        if m:
            pip_cmd = m.group(1).strip()
            uv_pip = pip_cmd.replace("pip install", "uv pip install")
            uv_pip += ' --python "$dir\\.venv\\Scripts\\python.exe"'
            new_post.append('uv venv "$dir\\.venv"')
            new_post.append(uv_pip)
            continue

        # 匹配缩进格式的 pip install (githacker conda 块内)
        # json.loads 后格式为 "    pip install -e \"$dir\"" -> Python str: "    pip install -e \"$dir\""
        m2 = re.match(r'^\s*pip install (.+)$', line)
        if m2:
            pip_args = m2.group(1).strip()
            uv_pip = f'uv pip install {pip_args} --python "$dir\\.venv\\Scripts\\python.exe"'
            new_post.append('uv venv "$dir\\.venv"')
            new_post.append(uv_pip)
            continue

        new_post.append(line)

    # 后处理：折叠无用的 conda if/else 块（两个分支相同时简化为直接 uv）
    new_post = _collapse_conda_ifelse(new_post)

    if not new_post:
        del data["post_install"]
    else:
        data["post_install"] = new_post[0] if len(new_post) == 1 else new_post


def _collapse_conda_ifelse(lines):
    """如果 conda if/else 的两个分支内容相同，折叠为直接的 uv 命令"""
    # 匹配模式:
    # "if (Get-Command conda ... {",
    #   "    pip install ...",      ← 分支A
    # "} else {",
    #   "    pip install ...",      ← 分支B (相同)
    # "}"
    # → 替换为直接的 uv venv + uv pip install
    for i, line in enumerate(lines):
        if 'if (Get-Command conda' in line:
            # 找到 if 块
            brace_count = 0
            j = i
            branches = {"if_body": [], "else_body": []}
            current = "if_body"
            for j in range(i + 1, len(lines)):
                lj = lines[j]
                if re.search(r'\}\s*else\s*\{', lj):
                    current = "else_body"
                    continue
                if re.search(r'\}\s*$', lj) and 'else' not in lj:
                    break
                if current == "if_body":
                    branches["if_body"].append(lj)
                else:
                    branches["else_body"].append(lj)
            # 检查两分支是否相同
            if (branches["if_body"] and branches["else_body"] and
                    branches["if_body"] == branches["else_body"] and
                    len(branches["if_body"]) == 2):  # uv venv + uv pip install
                # 替换整个块
                return lines[:i] + branches["if_body"] + lines[j + 1:]
    return lines


def process_file(filepath):
    """处理单个 JSON 文件"""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    if "python3env" not in content and "\\\\venv" not in content:
        return False

    original = content
    data = json.loads(content)

    fix_suggest(data)
    fix_pre_install(data)
    fix_post_install(data)

    new_content = json.dumps(data, indent=4, ensure_ascii=False)
    # 将 venv 目录名统一改为 .venv
    # JSON 中 "uv venv \"$dir\\venv\"" → "uv venv \"$dir\\.venv\""
    new_content = new_content.replace(r'\"$dir\\venv\"', r'\"$dir\\.venv\"')
    new_content = new_content.replace(r'\"$dir\\venv\\', r'\"$dir\\.venv\\')
    if not new_content.endswith("\n"):
        new_content += "\n"

    if new_content != original:
        with open(filepath, "w", encoding="utf-8", newline="\n") as f:
            f.write(new_content)
        return True
    return False


def main():
    updated = []
    errors = []
    all_files = []
    for root, dirs, files in os.walk(BUCKET_DIR):
        for fname in files:
            if fname.endswith(".json"):
                all_files.append(os.path.join(root, fname))
    all_files.sort()

    for fpath in all_files:
        relpath = os.path.relpath(fpath, BUCKET_DIR)
        try:
            if process_file(fpath):
                updated.append(relpath)
        except Exception as e:
            errors.append((relpath, str(e)))
            print(f"ERROR processing {relpath}: {e}")

    print(f"\nUpdated {len(updated)} files:")
    for f in updated:
        print(f"  {f}")
    if errors:
        print(f"\nErrors ({len(errors)}):")
        for f, e in errors:
            print(f"  {f}: {e}")


if __name__ == "__main__":
    main()
