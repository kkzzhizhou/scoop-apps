#!/usr/bin/env python3
"""将含换行符的单行 pre_install 字符串按换行符拆分为数组"""

import json
import os
import glob

BUCKET_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "bucket")

count = 0
all_files = glob.glob(os.path.join(BUCKET_DIR, "**", "*.json"), recursive=True)

for fpath in sorted(all_files):
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()

    data = json.loads(content)
    pre = data.get("pre_install")
    if not pre:
        continue
    original = pre

    if isinstance(pre, str):
        pre = [pre]

    new_pre = []
    changed = False
    for line in pre:
        if "\n" in line:
            parts = line.split("\n")
            new_pre.extend(parts)
            changed = True
        else:
            new_pre.append(line)

    if not changed and isinstance(original, list):
        continue

    data["pre_install"] = new_pre[0] if len(new_pre) == 1 else new_pre

    new_content = json.dumps(data, indent=4, ensure_ascii=False)
    if not new_content.endswith("\n"):
        new_content += "\n"

    with open(fpath, "w", encoding="utf-8", newline="\n") as f:
        f.write(new_content)

    rel = os.path.relpath(fpath, BUCKET_DIR)
    print(f"  {rel}")
    count += 1

print(f"\nConverted {count} files.")
