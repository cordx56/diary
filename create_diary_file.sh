#!/bin/bash

dir_path="src/posts/`date +%Y/%m/%d`"
mkdir -p $dir_path

for i in {1..9} ; do
    file_path="$dir_path/0$i.md"
    if [ ! -f "$file_path" ]; then
        echo "$file_path"
        cat <<EOF > "$file_path"
---
title: 
date: `date +"%Y-%m-%d %H:%M:%S"`
---
EOF

        break
    fi
done

nvim "$file_path"
