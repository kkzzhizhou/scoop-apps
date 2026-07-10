#!/usr/bin/env python3
"""
对包含 "uv run python" 的 Python Scoop 包执行卸载后重新安装。

用法:
    python reinstall-uv-python.py --dry-run    # 预览
    python reinstall-uv-python.py --force      # 直接执行
    python reinstall-uv-python.py              # 交互确认
"""

import os
import glob
import argparse

BUCKET_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "bucket")
SCOOP_APPS_DIR = r"D:\Tools\apps"


def find_target_packages():
    """扫描 bucket 目录，找出包含 'uv run python' 的包名"""
    packages = []
    for fpath in sorted(glob.glob(os.path.join(BUCKET_DIR, "**", "*.json"), recursive=True)):
        with open(fpath, "r", encoding="utf-8") as f:
            if "uv run python" in f.read():
                pkg_name = os.path.splitext(os.path.basename(fpath))[0]
                packages.append(pkg_name)
    return packages


def get_installed_packages():
    """通过文件系统检查已安装的包名集合"""
    installed = set()
    if not os.path.isdir(SCOOP_APPS_DIR):
        print(f"  警告: {SCOOP_APPS_DIR} 不存在")
        return installed
    for entry in os.listdir(SCOOP_APPS_DIR):
        entry_path = os.path.join(SCOOP_APPS_DIR, entry)
        if os.path.isdir(entry_path):
            installed.add(entry)
    return installed


def scoop_uninstall(pkg_name):
    """卸载包，返回是否成功"""
    print(f"  卸载 {pkg_name} ...", flush=True)
    rc = os.system(f"scoop uninstall {pkg_name}")
    return rc == 0


def scoop_install(pkg_name):
    """通过包名安装（使用本地 bucket），返回是否成功"""
    print(f"  安装 {pkg_name} ...", flush=True)
    rc = os.system(f"scoop install {pkg_name}")
    return rc == 0


def main():
    parser = argparse.ArgumentParser(description="卸载并重装含 uv run python 的 Scoop 包")
    parser.add_argument("--dry-run", action="store_true", help="仅预览，不执行")
    parser.add_argument("--force", "-f", action="store_true", help="跳过确认直接执行")
    args = parser.parse_args()

    # 1. 扫描目标包
    print("=== 扫描包含 'uv run python' 的配置 ===")
    target_packages = find_target_packages()
    print(f"找到 {len(target_packages)} 个包")

    if not target_packages:
        print("没有需要处理的包。")
        return

    # 2. 检查安装状态
    print("\n=== 检查安装状态 ===")
    installed = get_installed_packages()

    to_process = [p for p in target_packages if p in installed]
    to_skip = [p for p in target_packages if p not in installed]

    print(f"已安装(将重装): {len(to_process)} 个")
    print(f"未安装(跳过)  : {len(to_skip)} 个")
    for p in to_skip:
        print(f"  跳过: {p}")

    if not to_process:
        print("\n没有已安装的包需要处理。")
        return

    # 3. 确认
    if not args.force and not args.dry_run:
        print(f"\n将要卸载并重装 {len(to_process)} 个包")
        print("警告: 卸载会删除应用目录！")
        confirm = input("输入 'yes' 确认: ")
        if confirm.strip().lower() != "yes":
            print("已取消。")
            return

    # 4. 预览模式
    if args.dry_run:
        print("\n=== [DryRun] ===")
        for p in to_process:
            print(f"  scoop uninstall {p}  ->  scoop install {p}")
        print(f"\n共 {len(to_process)} 个 (DryRun, 未执行)")
        return

    # 5. 执行
    print("\n=== 开始重装 ===")
    success = []
    failed = []
    total = len(to_process)

    for i, pkg in enumerate(to_process, 1):
        print(f"\n[{i}/{total}] {pkg}")
        if not scoop_uninstall(pkg):
            failed.append(pkg)
            continue
        if scoop_install(pkg):
            success.append(pkg)
        else:
            failed.append(pkg)

    # 6. 总结
    print(f"\n=== 完成 ===")
    print(f"成功: {len(success)} / {total}")
    if failed:
        print(f"失败: {len(failed)}")
        for p in failed:
            print(f"  {p}")


if __name__ == "__main__":
    main()
