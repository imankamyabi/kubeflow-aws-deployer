# Kubeflow AWS Deployer
Shell script to create an EKS cluster and deploy Kubeflow to it


Usage:
```bash
# Download the script
curl --silent https://raw.githubusercontent.com/imankamyabi/kubeflow-aws-deployer/master/deploy_eks.sh --output deploy_eks.sh
# Run:
./deploy_eks.sh [cluster name] [instance type] [cluster size]
# Example: ./deploy_eks.sh devkfworkshop m5.large 6
```

Author: Iman Kamyabi
Reference: https://eksworkshop.com/