# Code Repository for Video Demo
## Continuous Deployment to AWS EC2 using Github Actions
This repository contains the example application used in the video demo [Continuous Deployment to AWS EC2 using Github Actions](https://www.youtube.com/watch?v=B04c0lbzMC4). The instructions for the demo are also available as a written tutorial below.

### Agenda
1. Introduction
2. Prerequisites
3. The CD pipeline
4. Set up EC2
5. Set up S3 Bucket
6. Create build script
7. CodeDeploy setup
8. Set up Github actions

### Introduction
Why continuous deployment? Because it simplifies the process of validating changes to the code base and deployment of the application to production. This tutorial will demonstrate how to set up a simple CD pipeline for autonomous deployment.

### Prerequisites
The prerequisites for this tutorial are the following:
 - A React application stored in a Github repository
 - An AWS account to create EC2 instances.
 - AWS CLI to be installed and configured on your local machine with access keys.

### The CD pipeline
The CD pipeline which will be set up is the following:
 - New code gets pushed to the main branch of the repo, it will trigger a github action
 - The code will be built and pushed to a S3 bucket
 - The application will be deployed on an EC2 instance using AWS CodeDeploy and be available through the IP address of the EC2 instance.

### Set up EC2
1. Create a new IAM role and attach the S3ReadOnlyAccess permission. The role is used to give the EC2 read access to the S3 bucket where the source code will be stored.
2. Navigate to EC2, launch a new instance, choose Ubuntu 20.04 as OS. Select the amount of storage needed for the application.  
3. Configure the instance by adding the following script in the user data field.

```
#!/bin/bash
apt update
apt install nodejs -y
apt install npm -y
npm i npm@latest -g
npm i n -g
n stable

apt install awscli -y
apt-get install ruby -y
apt-get install wget -y
cd /home/ubuntu
wget https://aws-codedeploy-eu-west-2.s3.eu-west-2.amazonaws.com/latest/install
chmod +x ./install
./install auto

apt-get install mysql-server -y
```
 This will ensure that npm, AWS CLI and other necessary software will be installed on the EC2 instance.
4. Add a key-value tag, save or remember the tag because it will be used as identification when setting up codedeploy.
5. Set up a security group which is a set of firewall rules for the instance. If you want your app to run on port 80 you will have to set up apache or nginx. We will run our app on port 3000.

### Set up S3 Bucket
1. Let’s continue with setting up a S3 bucket. The S3 bucket will be used as storage and the source code of the application will be pushed into it before deployment.
2. Create a new S3 bucket, name it and make sure to turn on versioning.

### Create build script
1. Create `build.sh` in the project root. The script will create a new folder, move all the files into it, install dependencies, compile and zip the artifacts. Finally it uploads the zip-file to the S3 bucket (see `build.sh` in the root of this repo).

### CodeDeploy setup
The AWS CodeDeploy service can be used to deploy to an EC2 instance. The configuration of CodeDeploy is defined in a file named `appspec.yml.` Three hooks are defined, which will run these three scripts:
  - The first script is the cleanup script (`shScripts/clean.sh`). It simply removes the previous deployed app
  - Then we have the dependencies script (`shScripts/dependencies.sh`), which runs npm install
  - Lastly we have the runApp script (`shScripts/runApp.sh`), which loads and runs our application as a linux service
We therefore need to create a `.service` file for our app. This file instructs systemctl how to run the app and restart it if it crashes.

When all these files have been created you're ready to run the build script. Check that the application has been compiled, zipped and uploaded to the S3 bucket.

It’s time for creating a service role to give CodeDeploy the correct permissions.

1. Create a json-file in the project root called CodeDeployRole.json and add the following script
```
{"Version": "2012-10-17",     
    "Statement": [
        {
            "Sid": "",      
            "Effect": "Allow",         
            "Principal": {               
                "Service": [                
                               "codedeploy.amazonaws.com"      
                           ]         
            },
            "Action": "sts:AssumeRole"
        }     
    ]
}
```
2. The IAM role can then be created using AWS CLI by running the following command

```
aws iam create-role \
--role-name CodeDeployServiceRole \
--assume-role-policy-document file://CodeDeployRole.json
```

from the terminal at your project root.
3. The ARN role should be outputted, copy and save this since it’s needed when creating the deployment group.
4. Attach the managed policy for the CodeDeploy to the created role

```
aws iam attach-role-policy \
--role-name CodeDeployServiceRole \
--policy-arn arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole
```

5. Let’s create the application, run this command

```
aws deploy create-application --application-name devops-demo
```

6. To create a deployment group, run this command

```
aws deploy create-deployment-group \
--application-name devops-demo \
--deployment-group-name devops-demo-dgroup1 \
--ec2-tag-filters Key=devops,Value=demo,Type=KEY_AND_VALUE \
--service-role-arn arn:aws:iam::016502426170:role/CodeDeployRole
```

remember to replace the --ec2-tag-filters key-value to match the EC2 instance created earlier and change the --service-role-arn to the arn copied in the last step. Lastly name the deployment group.

7. Create a deploy script and add the following

```
aws deploy create-deployment \
--application-name devops-demo \
--deployment-config-name CodeDeployDefault.OneAtATime \
--deployment-group-name devops-demo-dgroup1 \
--description "$1" \
--s3-location bucket=devops-demo-video,bundleType=zip,key=devops-demo-dist.zip \
--ignore-application-stop-failures
```

Ensure to set the correct bucket name and key value for the --s3-location.
8. Before executing the script, give the file executable permissions `chmod u+x deploy.sh` and then run the script.
9. Navigate to codedeploy to view all deployments, you should see it running or being finished.
10. Put your EC2 instance IP with the correct port into a web browser and you should get a response from your application.

### Set up Github actions
1. Let’s set up github actions to autonomously deploy the application. Create the github action configuration file in `.github/workflows` (see `.github/workflows/deploy.yml`)
2. First, configure the action name, and make it run on pushes and pull requests to the main branch
3. Set up the deployment job. Configure some environment variables needed to run the build and deploy scripts in the action.
4. Configure the node js version.
5. Then specify the job steps
  - Git checkout fetches the commit from the repo
  - Configure aws in three steps. Set the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and the region. The access keys need to be added as secrets in the repository.
6. Finally add one step for running the build script and one for running the deploy script.
7. The Github action is now done, make a push and the application should be deployed.
8. In reality you would want your CD pipeline to depend on a successful run of a CI pipeline. This can be done like this.
Now you have finished setting up a CD workflow for your React application using github actions and AWS.
