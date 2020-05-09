#!/usr/bin/env python
# -*- coding: utf-8 -*-
""" @todo add docstring """

# ### imports ###

from __future__ import (
    absolute_import,
    division,
    print_function  # ,
    #  unicode_literals
)

import datetime
# import fnmatch
import glob
# import json
import re
import os
import subprocess
import sys

path = os.environ['PATH']

paths = path.split(';')

seen_paths = {}

exes = {}

include_dirs = []  # ['c:\\bin']
exclude_dirs = [
    r'%USERPROFILE%\scoop\apps\imagemagick\current',
    r'%SystemDrive%\GnuWin32\bin',
    r'%USERPROFILE%\scoop\apps\git\current\mingw64\bin'
]

for i, dir in enumerate(exclude_dirs):
    exclude_dirs[i] = os.path.expandvars(dir)

max_path = 0

map = {}

for path in paths:
    p = path.lower().rstrip("\\")
    if len(p) == 0:
        continue
    if p in seen_paths:
        seen_paths[p] += 1
        continue
    seen_paths[p] = 1
    if not os.path.exists(path):
        print("path not found: '%s'" % path)
        continue
    skip = False
    for dir in exclude_dirs:
        if dir.upper().find(path.upper()) >= 0:
            skip = True
    if skip:
        continue
    os.chdir(path)
    files = glob.glob("*.exe")
    files += glob.glob("*.com")
    # files += glob.glob("*.dll")
    files += glob.glob("*.cmd")
    files += glob.glob("*.bat")
    for file in files:
        file = file.lower()
        if file not in exes:
            exes[file] = []
        exes[file].append(path)
        if file not in map:
            map[file] = {}
        map[file][path] = 1

files = []

for file, paths in exes.items():
    if len(paths) > 1:
        files.append(file)

files.sort()

for file in files:
    for path in exes[file]:
        max_path = max(max_path, len(path))

for file in files:
    skip = False
    for dir in include_dirs:
        for path in map[file]:
            if dir.upper().find(path.upper()) >= 0:
                skip = True
                break
    if skip:
        continue
    print("%s:" % file)
    for path in exes[file]:
        full = path + '\\' + file
        # q = '"%s"' % full
        # print("q=%s" % q)
        out = 'n/a'
        if re.search('(com|dll|exe)$', file) is not None:
            p = subprocess.Popen(
                ['sigcheck.exe', '-nobanner', '-n', full],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
            out, err = p.communicate()
            out = out.strip()
        mtime = os.path.getmtime(full)
        out += datetime.datetime.fromtimestamp(mtime).strftime(
            ' (%Y-%m-%d %H:%M:%S)')
        print("  %*s: %s" % (-max_path, path, out))

sys.exit(0)
