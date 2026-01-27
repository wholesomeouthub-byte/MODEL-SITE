import re
import sys

VOID_TAGS = {'area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr'}

def strip_script_style(html):
    # remove script and style contents to avoid false tag matches
    html = re.sub(r'<script[\s\S]*?<\/script>', '<script></script>', html, flags=re.IGNORECASE)
    html = re.sub(r'<style[\s\S]*?<\/style>', '<style></style>', html, flags=re.IGNORECASE)
    return html

def find_tags(html):
    pattern = re.compile(r'<\s*(\/)?\s*([a-zA-Z0-9:-]+)([^>]*)>', re.IGNORECASE)
    return [(m.group(1), m.group(2).lower(), m.group(3), m.start()) for m in pattern.finditer(html)]

def validate(path):
    with open(path, 'r', encoding='utf-8') as f:
        html = f.read()

    issues = []

    # basic checks
    if '<!doctype' not in html.lower():
        issues.append('Missing DOCTYPE')

    cleaned = strip_script_style(html)
    tags = find_tags(cleaned)

    stack = []
    for closing, tag, attr, pos in tags:
        if closing:
            if stack and stack[-1] == tag:
                stack.pop()
            else:
                # try to find matching open in stack
                if tag in stack:
                    while stack and stack[-1] != tag:
                        issues.append(f'Unclosed tag <{stack.pop()}> before closing </{tag}> at pos {pos}')
                    if stack and stack[-1] == tag:
                        stack.pop()
                else:
                    issues.append(f'Unmatched closing tag </{tag}> at pos {pos}')
        else:
            # self-closing or void tags
            if tag in VOID_TAGS or attr.strip().endswith('/'):
                continue
            # push opening tag
            stack.append(tag)

    for t in reversed(stack):
        issues.append(f'Unclosed tag <{t}>')

    # duplicate IDs
    ids = re.findall(r'id\s*=\s*"([^"]+)"', html)
    dup = {i for i in ids if ids.count(i) > 1}
    if dup:
        issues.append('Duplicate id(s): ' + ', '.join(sorted(dup)))

    # images without alt
    imgs = re.findall(r'<img([^>]+)>', html, flags=re.IGNORECASE)
    imgs_missing = []
    for i, attrs in enumerate(imgs, start=1):
        if not re.search(r'\salt\s*=\s*"', attrs, flags=re.IGNORECASE):
            imgs_missing.append(i)
    if imgs_missing:
        issues.append(f'{len(imgs_missing)} <img> tag(s) missing alt attribute (indices: {imgs_missing[:5]})')

    # check addToCart definition when used
    if re.search(r'addToCart\s*\(', html) and not re.search(r'function\s+addToCart\s*\(|const\s+addToCart\s*=|let\s+addToCart\s*=', html):
        issues.append('`addToCart` is referenced but no definition found')

    # output
    if issues:
        print('Validation issues found:')
        for it in issues:
            print('- ' + it)
        return 2
    else:
        print('No obvious HTML structural issues detected.')
        return 0

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Usage: html_validator.py <file.html>')
        sys.exit(1)
    path = sys.argv[1]
    rc = validate(path)
    sys.exit(rc)
