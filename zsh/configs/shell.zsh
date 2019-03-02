function ac_app() {
  aws ec2 describe-instances --filters "Name=tag:Name,Values=account-creation-$1*-app*" "Name=instance-state-name,Values=running" | jq '.Reservations[].Instances[0] | .PrivateIpAddress' -r
}

function ec2_by_name() {
  aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" "Name=instance-state-name,Values=running" | jq -r '.Reservations[].Instances[0]'
}

function ac_setup() {
  export BH=`bh`
  export AC_APP=`ac_app $1`
}

function ami() {
  curl -s "https://amiquery.intuit.com/amis?region=$AWS_DEFAULT_REGION&tag=virtualization:hvm&tag=status:available&tag=osVersion:$1" |  jq -r '.[0] | .id' 
}

function ocs() {
  if [ -f ~/Downloads/AWS_Keys.txt ]; then 
    mv ~/Downloads/AWS_Keys.txt ~/.aws_creds
  fi
  sed -i .bak 's/^\(aws_access_key_id\)/export AWS_ACCESS_KEY_ID/' ~/.aws_creds
  sed -i .bak 's/^\(aws_secret_access_key\)/export AWS_SECRET_ACCESS_KEY/' ~/.aws_creds
  sed -i .bak 's/^\(aws_session_token\)/export AWS_SESSION_TOKEN/' ~/.aws_creds
  source ~/.aws_creds
}

function tto_tk() {
# Set these appropriately
export AWS_DEFAULT_REGION=us-west-2
export TK_AWS_SSH_KEY_ID=mcowgill-id-rsa-pub
export TK_SSH_KEY=/Users/mcowgill1/.ssh/id_rsa
VPC_ID=vpc-990c2dfe

# These can be looked up
export TK_REGION=$AWS_DEFAULT_REGION
export TK_INSTANCE_TYPE=t2.micro
export TK_SUBNET_ID=$(aws cloudformation list-exports --query "Exports[?Name=='$VPC_ID:private-subnet-az1:id'].Value" --output text)
export TK_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=tag-value,Values=test-kitchen-security-group-$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text)
}

function amfa() {
  oathtool --base32 --totp $(pass mfa/$1)
}
