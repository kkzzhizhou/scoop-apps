import os
from string import Template
from icon_table import gen_icon_table

readme_template = os.environ.get(
    'README_TEMPLATE', 'templates/README.template.md'
)

with open(readme_template, 'r') as file:
    template_string = file.read()

template = Template(template_string)
data = {'icon_table': gen_icon_table()}

print(template.safe_substitute(data))
