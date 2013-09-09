#!/bin/bash

## almost all systems will have diff here, but you may need to change this
DIFF=/usr/bin/diff

for file in *.auto.txt
do
    echo "checking $file"
    diff $file ../tests/$file
done
