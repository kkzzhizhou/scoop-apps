#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" @todo add docstring """

import io
import json
import os
import re
import subprocess
import sys

home = os.path.expanduser('~')

if len(sys.argv) > 1:
    nirsoft_dir = sys.argv[1]
else:
    nirsoft_dir = os.path.join(home, 'scoop/apps/nirlauncher/current/NirSoft')
    if not os.path.exists(nirsoft_dir):
        nirsoft_dir = os.path.join(os.getenv('SCOOP'), 'apps/nirlauncher/current/NirSoft')
nirsoft_dir = os.path.normpath(nirsoft_dir)

nirsoft_nlp = os.path.normpath(os.path.join(nirsoft_dir, 'nirsoft.nlp'))

if len(sys.argv) > 2:
    nirlauncher_json = sys.argv[2]
else:
    nirlauncher_json = os.path.join(os.path.dirname(nirsoft_dir), 'manifest.json')
nirlauncher_json = os.path.normpath(nirlauncher_json)

try:
    with io.open(nirlauncher_json, 'r', encoding='utf-8') as f:
        data = json.load(f)
except IOError as err:
    exit(err)

try:
    with io.open(nirsoft_nlp, 'r', encoding='utf-8') as f:
        lines = f.readlines()
except IOError as err:
    exit(err)

exes = {}

h = {}

for line in lines:
    if re.match(r'\[', line):
        if 'exe' in h:
            if h['exe']:
                exes[os.path.basename(h['exe'])] = h
        h = {}
        continue
    m = re.match(r'([^=]+)=(.*)', line)
    if not m:
        continue
    k = m.group(1).strip()
    v = m.group(2).strip()
    h[k] = v

data['architecture']['32bit']['bin'] = ["Nirlauncher.exe"]
data['architecture']['32bit']['shortcuts'] = [[
    "Nirlauncher.exe",
    "Nirlauncher - Run over 200 freeware utilities from nirsoft.net"
]]
data['architecture']['64bit']['bin'] = ["Nirlauncher.exe"]
data['architecture']['64bit']['shortcuts'] = [[
    "Nirlauncher.exe",
    "Nirlauncher - Run over 200 freeware utilities from nirsoft.net"
]]

for base in sorted(exes, key=str.lower):
    h = exes[base]
    desc = h['ShortDesc']
    desc = re.sub(r'"', "'", desc)
    desc = re.sub(r'[/\\]', ",", desc)
    desc = re.sub(r'[<>\|\?\*:/]', "", desc)

    desc = desc.rstrip('.')
    if desc:
        desc = desc[0].upper() + desc[1:]
    print("%-25s %s" % (os.path.splitext(base)[0], desc))

    path = os.path.join('NirSoft', h['exe'])
    path = re.sub(r'\\', '/', path)
    data['architecture']['32bit']['bin'].append(path)

    # Get binary information
    fullpath = os.path.join(nirsoft_dir, h['exe'])
    stdout = subprocess.check_output(['7z.exe', 'l', fullpath], universal_newlines=True)

    if re.search('Subsystem = Windows GUI', stdout):
        if 'AppName' in h and h['AppName']:
            appname = h['AppName']
        else:
            appname = os.path.splitext(base)[0]
        name = '%s/%s' % ('NirSoft', appname)
        if desc:
            name += ' - ' + desc
        data['architecture']['32bit']['shortcuts'].append([path, name])
    if 'exe64' not in h or not h['exe64']:
        data['architecture']['64bit']['bin'].append(path)
        if re.search('Subsystem = Windows GUI', stdout):
            data['architecture']['64bit']['shortcuts'].append([path, name])
        continue

    path = os.path.join('NirSoft', h['exe64'])
    path = re.sub(r'\\', '/', path)
    data['architecture']['64bit']['bin'].append(path)
    if re.search('Subsystem = Windows GUI', stdout):
        data['architecture']['64bit']['shortcuts'].append([path, name])

json_dump = json.dumps(data, sort_keys=False, indent=4, separators=(',', ': '))

nirlauncher_tmp = nirlauncher_json + '.tmp'

try:
    with io.open(nirlauncher_tmp, 'w', newline='\n', encoding='utf-8') as f:
        f.write(json_dump)
        f.write('\n')
except IOError as err:
    exit(err)

try:
    os.remove(nirlauncher_json)
    os.rename(nirlauncher_tmp, nirlauncher_json)
except IOError as err:
    exit(err)
