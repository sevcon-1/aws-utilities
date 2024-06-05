#!/bin/bash

#trap quit_vault EXIT

# Check if an environment has been provided
if [ -z "$1" ]; then
  echo "Usage: ./ssm.sh [aws-profile][ec2 instance id]"
  echo "e.g. ./ssm.sh spm-dev dev03"
  exit 1
fi

stage="$1"
ec2_instance="$2"

# Set up the tag name/value and get ec2 instance id
tag_name="Name"
tag_value="$ec2_instance-SPM-Db-primary"
echo $tag_value
iid=$(aws-vault exec $stage -- aws ec2 describe-instances --filters "Name=tag:$tag_name,Values=$tag_value" --query "Reservations[].Instances[0].InstanceId" --output text)

if [ -z "$iid" ]; then
  echo "Error: unable to find an instance id for $ec2_instance in account $stage"
  exit 1
fi

echo "Attempting connection to: $ec2_instance - $iid"

# Connect to instance
aws-vault exec $stage -- aws ssm start-session --target "$iid"
