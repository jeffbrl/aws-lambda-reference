#!/bin/bash +xe

lambda_function_name=add
lambda_execution_role_name=lambda_basic_execution_role_cli
lambda_execution_access_policy_name=lambda_basic_policy_cli

lambda_execution_role_arn=$(aws iam create-role \
  --role-name "$lambda_execution_role_name" \
  --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }' \
  --output text \
  --query 'Role.Arn'
)
echo "arn: $lambda_execution_role_arn"

aws iam put-role-policy \
  --role-name "$lambda_execution_role_name" \
  --policy-name "$lambda_execution_access_policy_name" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*"
      }]
  }'

zip main.zip main.py

# wait for policy to be assigned to role
# https://stackoverflow.com/questions/36419442/the-role-defined-for-the-function-cannot-be-assumed-by-lambda
sleep 8


aws lambda create-function --function-name $lambda_function_name \
--zip-file fileb://main.zip \
--role $lambda_execution_role_arn \
--handler main.add --runtime python3.7
