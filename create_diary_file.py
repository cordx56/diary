#!/usr/bin/env python3
import os
import subprocess
import tempfile
import yaml
import datetime

def fetch_frontmatter(text):
    txtarr = text.strip().split('\n')
    if txtarr[0] == '---':
        for i in range(1, len(txtarr)):
            if txtarr[i] == '---':
                return yaml.safe_load('\n'.join(txtarr[1:i]))
    return {}

def delete_frontmatter(text):
    txtarr = text.strip().split('\n')
    if txtarr[0] == '---':
        for i in range(1, len(txtarr)):
            if txtarr[i] == '---':
                return '\n'.join(txtarr[i + 1:])

def dump_frontmatter(obj):
    return '---\n' + yaml.dump(obj) + '---\n'

tmpfile = tempfile.mkstemp('.md')
os.write(tmpfile[0], b'''---
title: 
---
''')
os.close(tmpfile[0])
subprocess.run(['/bin/bash', '-c', 'nvim ' + tmpfile[1]])

now = datetime.datetime.now()

with open(tmpfile[1]) as f:
    text = f.read()
    fm = fetch_frontmatter(text)
    fm['date'] = now.strftime('%Y-%m-%d %H:%M:%S')
    text = dump_frontmatter(fm) + delete_frontmatter(text)

dirpath = 'src/posts/' + now.strftime('%Y/%m/%d')
os.makedirs(dirpath, exist_ok=True)
for i in range(1, 100):
    filepath = dirpath + '/{:02}.md'.format(i)
    if not os.path.exists(filepath):
        with open(filepath, 'w') as f:
            f.write(text)
            print(text)
        break

os.remove(tmpfile[1])
