function vpc() {
  NUM=0
  if [[ -n $1 ]]; then
    NUM=$1
  fi
  aws ec2 describe-vpcs | jq -r ".Vpcs[$NUM].VpcId"
}

function vpcs() {
  aws ec2 describe-vpcs |\
    jq -r '.Vpcs[] | {vpc_id: .VpcId, cidr: .CidrBlock, name: .Tags[] | select(.Key=="Name") | .Value}'
}

function bsg() {
  VPC=`vpc`
  if [[ -n $1 ]]; then
    VPC=`vpc $1`
  fi
  aws ec2 describe-security-groups \
    --filters "Name=tag:Type,Values=Bastion" "Name=vpc-id,Values=$VPC" \
    | jq -r '.SecurityGroups[] | {id: .GroupId, name: .GroupName}'
}

function sub_ids() {
  aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Private*" | jq -r '[.Subnets[].SubnetId] | join(",")'
}

function subnet_type() {
  TYPE=Private
  VPC=`vpc 0`
  if [[ -n $1 ]]; then
    TYPE=$1
  fi
  if [[ -n $2 ]]; then
    VPC=`vpc $2`
  fi
  aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=$TYPE" "Name=vpc-id,Values=$VPC" \
    | jq -r '[.Subnets[].SubnetId] | join(",")'
}

function bh() {
  VPC=`vpc 0`
  if [[ -n $1 ]]; then
    VPC=`vpc $1`
  fi
 aws ec2 describe-instances \
    --filters "Name=tag:Service,Values=bastion" "Name=vpc-id,Values=$VPC" \
    | jq -r '.Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp'
}

function aws_url() {
  echo "https://$1.signin.aws.amazon.com/console"
}

function bastion_sg_ingress() {
  aws ec2 describe-security-groups \
    --filter "Name=ip-permission.cidr,Values=65.204.229.0/24" \
    "Name=ip-permission.from-port,Values=22" \
    | jq -r '.SecurityGroups[].GroupId'
}

function authorize_bastion_ingress() {
  aws ec2 authorize-security-group-ingress \
    --group-id `bastion_sg_ingress` \
    --protocol tcp \
    --port 22 \
    --cidr $(wget http://ipinfo.io/ip -qO -)/32
}

function revoke_bastion_ingress() {
  aws ec2 revoke-security-group-ingress \
    --group-id `bastion_sg_ingress` \
    --protocol tcp \
    --port 22 \
    --cidr $(wget http://ipinfo.io/ip -qO -)/32
}

function clear_aws_creds() {
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE
unset AWS_DEFAULT_PROFILE
}

function make_tf_bucket() {
  account=$(aws sts get-caller-identity | jq -r '.Account')
  bucket=tf-state-${account}-${AWS_DEFAULT_REGION}
  aws s3api create-bucket \
    --bucket ${bucket} \
    --region ${AWS_DEFAULT_REGION} \
    --create-bucket-configuration LocationConstraint=${AWS_DEFAULT_REGION}
  aws s3api put-bucket-versioning --bucket ${bucket} \
    --versioning-configuration Status=Enabled
}

function ikp() {
  aws ec2 import-key-pair \
    --key-name mcowgill-id-rsa \
    --public-key-material "$(cat ~/.ssh/id_rsa.pub)"
}
