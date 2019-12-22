#!/bin/bash

lambda_function_name=add
log_group_name=lambda_function_name
lambda_execution_role_name=lambda_basic_execution_role_cli 
lambda_execution_access_policy_name=lambda_basic_policy_cli

rm -f main.zip
aws lambda delete-function --function-name $lambda_function_name

aws iam delete-role-policy \
  --role-name "$lambda_execution_role_name" \
  --policy-name "$lambda_execution_access_policy_name"

aws iam delete-role --role-name $lambda_execution_role_name

log_stream_names=$(aws logs describe-log-streams \
  --log-group-name "$log_group_name" \
  --output text \
  --query 'logStreams[*].logStreamName') &&
for log_stream_name in $log_stream_names; do
  echo "deleting log-stream $log_stream_name"
  aws logs delete-log-stream \
    --log-group-name "$log_group_name" \
    --log-stream-name "$log_stream_name"
done

aws logs delete-log-group \
  --log-group-name "$log_group_name"
