# Kubeflow AWS Deployer
Shell script to create an EKS cluster and deploy Kubeflow to it. 

Majority of this script is taken from code snippets at eksworkshop.com and for the purpose of quickly spinning up Cloudflow by running a single script rather than running individual shell commands.

Recommended to run in Cloud9 workspace, t3.small instance type and "Amazon Linux" platform.

**Usage:**
```bash
./deploy_kubeflow.sh [cluster name] [instance type] [cluster size]
# Example: ./deploy_kubeflow.sh hellokf m5.large 6
```


## Step for deploying Kubeflow to AWS using Cloud9:

1- Set up Cloud9 workspace: https://eksworkshop.com/020_prerequisites/workspace/

2- Create IAM role for Cloud9 workspace: https://eksworkshop.com/020_prerequisites/iamrole/

3- Attach the IAM role to the Cloud9 instance: https://eksworkshop.com/020_prerequisites/ec2instance/

4- Navigate to Cloud9 environment > Prefrences > AWS Settings > Turn off AWS managed temporary credentials.

5- Start Cloud9 IDE, open a terminal and download the script.
```bash
curl --silent https://raw.githubusercontent.com/imankamyabi/kubeflow-aws-deployer/master/deploy_kubeflow.sh --output deploy_kubeflow.sh
```

6- Change the script permission to be executable:
```bash
chmod +x ./deploy_kubeflow.sh
```

7- Run the script:
```bash
./deploy_kubeflow.sh [cluster name] [instance type] [cluster size]
```
For example:
```bash
./deploy_kubeflow.sh hellokf m5.large 6
```

8- Click tools > Preview > Preview Running Application to open the dashboard.


## Delete the cluster:
To delete the EKS Cluster run the following command:
```bash
eksctl delete cluster --name=[cluster name]-eksctl
```
for example:
```bash 
eksctl delete cluster --name=hellokf-eksctl
```
