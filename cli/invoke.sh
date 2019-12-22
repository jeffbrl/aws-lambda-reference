#!/bin/bash
aws lambda invoke \
--invocation-type RequestResponse \
--function-name add \
--region us-east-1 \
--log-type Tail \
--payload '{"a":1, "b":2 }' \
outputfile.txt
cat outputfile.txt
echo " "
rm outputfile.txt
