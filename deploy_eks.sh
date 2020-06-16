#!/bin/bash

# Usage: ./deploy_eks.sh [cluster name] [instance type] [cluster size]
# Reference: https://eksworkshop.com/

export EKS_CLUSTER_NAME=$1
export EKS_INSTANCE_TYPE=$2
export EKS_CLUSTER_SIZE=$3

# Install Kubernetes tools
sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
sudo pip install --upgrade awscli && hash -r
sudo yum -y install jq gettext bash-completion moreutils
echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc
for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done
kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

# IAM
rm -vf ${HOME}/.aws/credentials

# REGION and ACCOUNT ID env set up
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region

# IAM test
# aws sts get-caller-identity --query Arn | grep kfworkshop-admin -q && echo "IAM role valid" || echo "IAM role NOT valid"

# SSH
ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N ""
aws ec2 import-key-pair --key-name "${EKS_CLUSTER_NAME}" --public-key-material file://~/.ssh/id_rsa.pub

# KMS
aws kms create-alias --alias-name "alias/${EKS_CLUSTER_NAME}" --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
export MASTER_ARN=$(aws kms describe-key --key-id alias/$EKS_CLUSTER_NAME --query KeyMetadata.Arn --output text)
echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile

# Install and configure eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
eksctl version
eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

# Create EKS cluster
cat << EOF > ${EKS_CLUSTER_NAME}.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${EKS_CLUSTER_NAME}-eksctl
  region: ${AWS_REGION}

managedNodeGroups:
- name: nodegroup
  instanceType: ${EKS_INSTANCE_TYPE}
  desiredCapacity: ${EKS_CLUSTER_SIZE}
  iam:
    withAddonPolicies:
      albIngress: true

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF
eksctl create cluster -f "${EKS_CLUSTER_NAME}.yaml"

# Test cluster
kubectl get nodes

# Export worker role name:
STACK_NAME=$(eksctl get nodegroup --cluster $EKS_CLUSTER_NAME-eksctl -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile