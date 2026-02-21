import os
import json
from pathlib import Path

def get_name(file):
    return file.name.removeprefix('wezterm-icon-').removesuffix('.png')

icon_dir = Path('alt-icons')
matrix = []

for file in icon_dir.glob('wezterm-icon-*.png'):
    matrix.append({
        'file': str(file),
        'ico': str(file.with_suffix('.ico')),
        'name': get_name(file)
    })

github_output = os.environ.get('GITHUB_OUTPUT')
if github_output:
    with open(github_output, 'a') as f:
        f.write(f"matrix={json.dumps(matrix)}\n")

