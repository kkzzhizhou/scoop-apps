import glob
import re

EXTRACT_INFO_REGEX = r"alt-icons/wezterm-icon-(?P<creator>.*?)-(?P<name>.*)\.png"
ICON_PATH_GLOB = "alt-icons/wezterm-icon-*.png"


def make_img(src: str, alt: str) -> str:
    return f'<img src="{src}" width="128" alt="{alt}">'


def make_desc(label: str, credit: str) -> str:
    return f"{label} <br /> {credit}"


def make_credit(creator: str) -> str:
    return f"[@{creator.lower()}](https://github.com/{creator.lower()})"


def make_img_alt(name):
    return f"{name} Icon"


def extract_info(filepath):
    pattern = re.compile(EXTRACT_INFO_REGEX)
    match = pattern.match(filepath)
    if not match:
        raise ValueError(f"Filename does not match expected pattern: {filepath}")

    creator = match.group("creator")
    name = match.group("name").replace("_", " ").title()
    credit = make_credit(creator)
    alt = make_img_alt(name)

    return filepath, name, credit, alt


def gen_icon_table(images_path_glob=ICON_PATH_GLOB):
    files = sorted(glob.glob(images_path_glob))

    # Build table rows
    # 4 columns = 2 x | icon | creator |
    rows = []
    for i in range(0, len(files), 2):
        cells = []
        for file in files[i : i + 2]:
            src, label, credit, alt = extract_info(file)
            img = make_img(src, alt)
            desc = make_desc(label, credit)
            cells.extend([img, desc])
        while len(cells) < 4:
            cells.extend(["", ""])
        rows.append("| " + " | ".join(cells) + " |")

    # Output markdown
    header = "| | | | |\n" + "|-|-|-|-|\n"

    return f"{header}" + "\n".join(rows)
