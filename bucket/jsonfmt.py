#!/usr/bin/env python
# -*- coding: utf-8 -*-
""" @todo add docstring """

# ### imports ###

from jsoncomment import JsonComment
# from jsonschema import validate

from collections import OrderedDict
import io
import json
import os
import pprint
import sys


def decode(s):
    if sys.version_info >= (3, 0):
        return s

    for encoding in 'utf-8-sig', 'utf-16':
        try:
            return s.decode(encoding)
        except UnicodeDecodeError:
            continue
    return s.decode('latin-1')


def touch(filename, mtime):
    with open(filename, 'a+'):
        pass
    os.utime(filename, (mtime, mtime))
    return 0

def add(key, old, new):
    if key in old:
        new[key] = old[key]
    return new

file = sys.argv[1]
if file == 'schema.json':
    sys.exit(0)
print('Updating %s' % file)

mtime = os.path.getmtime(file)

with open(file, 'r') as f:
    jstr = f.read()
    jstr_no_bom = decode(jstr)

parser = JsonComment(json)
json_data = parser.loads(jstr_no_bom)

keys = [
    '##',
    '_comment',
    'version',
    'description',
    'homepage',
    'license',
    'notes',
    'depends',
    'suggest',
    'cookie',
    'architecture',
    'url',
    'hash',
    'innosetup',
    'extract_dir',
    'extract_to',
    'pre_install',
    'installer',
    'post_install',
    'uninstaller',
    'bin',
    'shortcuts',
    'psmodule',
    'env_add_path',
    'env_set',
    'persist',
    'checkver',
    'autoupdate',
]

old_json = json_data
new_json = OrderedDict()
for key in keys:
    new_json = add(key, json_data, new_json)
    if key in old_json:
        del old_json[key]

if old_json:
    pprint.pprint(old_json)
    sys.exit(1)

new_data = json.dumps(
    new_json, sort_keys=False, indent=4, separators=(',', ': '), ensure_ascii=False)
# new_data = new_data.encode('utf-8')
new_data += "\n"
with io.open(file + '.tmp', 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(new_data)

if os.path.isfile(file + '.bak'):
    os.remove(file + '.bak')
os.rename(file, file + '.bak')
os.rename(file + '.tmp', file)

# touch(file, mtime)

sys.exit(0)
