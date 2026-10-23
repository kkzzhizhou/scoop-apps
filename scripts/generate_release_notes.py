import os
from string import Template
from icon_table import gen_icon_table

release_notes_template = os.environ.get(
    'RELEASE_NOTES_TEMPLATE','templates/RELEASE.template.md'
)

wezterm_release = os.environ.get('WEZTERM_RELEASE',"TESTING")

with open(release_notes_template, 'r') as file:
    template_string = file.read()

template = Template(template_string)
data = {
    'wezterm_release': wezterm_release,
    'icon_table': gen_icon_table()
}

print(template.safe_substitute(data))
