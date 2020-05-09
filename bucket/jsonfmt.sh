#!/usr/bin/env bash

jsons=${1:-*.json}

for i in ${jsons}; do
    python jsonfmt.py "$i"
done
