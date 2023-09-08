#!/bin/bash

# Array to hold mappings
# e.g. ["<environment>"]="<EC2 instance id>"
# Bash 4+
#declare -A mappings=(
#  ["xxx123"]="i-1234abcd"
#)

# Array for Bash < 4
# e.g. <environment>:<instance id>
#
# Add in instances here:
#
declare -a mappings=(
    "xxx:i-12345abcd"
)

# Check if an environment has been provided
if [ -z "$1" ]; then
  echo "Usage: ./script.sh [stage][ec2 instance id]"
  exit 1
fi

stage="$1"
ec2_instance="$2"

# Lookup the value in the array
# For Bash 4+
#iid="${mappings[$ec2_instance]}"

# Bash < 4 Loop split and get instance id ... 
for environment in "${mappings[@]}"; do

    key=${environment%%:*}
    val=${environment#*:}

    #echo "Key is: $key"
    #echo "Value is: $val"

    if [ "$key" == "$ec2_instance" ]; then
        iid="$val"
        break
    fi
done

# Check if the value exists
if [ -z "$iid" ]; then
  echo "Error: Unmapped environment - $ec2_instance"
  exit 1
fi

echo "Attempting connection to: $ec2_instance - $iid"

# Connect to instance
aws-vault exec $stage -- aws ssm start-session --target "$iid"
