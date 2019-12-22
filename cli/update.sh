#!/bin/sh

zip main.zip main.py
aws lambda update-function-code \
    --function-name  add \
    --zip-file fileb://main.zip
