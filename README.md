# Django AWS ECS Deployment with Terraform: Production-Ready Infrastructure Setup


## ✅ Prerequisites
Before starting, ensure you have the following:
- AWS CLI installed and configured with appropriate permissions. [Installing or updating to the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform installed (version v1.5.7). [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Docker installed. [Install Docker Engine](https://docs.docker.com/engine/install/)
- Python (v3.12.0)[https://www.python.org/downloads/](https://www.python.org/downloads/)
- Basic understanding of AWS services (VPC, ECS, RDS, ALB)

## Project Architecture diagram

## Project Structure

```bash
├── .gitignore
└── app   
│   ├── Dockerfile
│   ├── blog_app
│   │   ├── __init__.py
│   │   ├── asgi.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── manage.py
│   ├── db.sqlite3
│   └── requirements.txt
├── README.md
├── terraform

```

## Tech Stack Used in this Project

| Component           |  Service |
| ------------------- | ----------- |
|Container orchestration          | Amazon Elastic Container Service (ECS) |
| Image Storage       | Amazon Elastic Container Registry (ECR)  |
| Database (Optional) | RDS         |
| Networking          | VPC, ALB,SGs|
| Infra as Code       | Terraform   |
| Monitoring and Logging      | CloudWatch   |

## Step 1: Prepare Your Django Application

In this first step, we will create a Django application from scratch and dockerize the application using Docker. If you have an existing Django project that you will like to use , you can skip this first step if not lets get started. 

### Create a new Django app
1. Create a vitual environment 
```bash
    python -m venv env
```
2. activate the  vitual environment 
```bash
    source env/Scripts/activate
```
3. Create a directory for your app and cd into the directory
```bash
    mkdir app && cd app
```
4.a Install Django
```bash
    pip install django
```
4.b
Install gunicorn
```bash
 pip install gunicorn
```
5. Create a django blog app
```bash
    django-admin startproject blog_app .
```
6. start your app  
```bash
    django-admin startproject blog_app .
```
access the app using this url [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

7. create a requirements file for your django app
```bash
pip freeze > requirements.txt
```

### Dockerize  your Django  app 

1. Create a Dockerfile
In the app directory create a `Dockerfile`, copy and paste the code bellow and paste in the dockerfile
```bash
# Build stage
FROM python:3.12.0-slim-bookworm

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
 PYTHONUNBUFFERED=1

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create a user with UID 1000 and GID 1000
RUN groupadd -g 1000 appgroup && \
    useradd -r -u 1000 -g appgroup appuser
# Switch to this user
USER 1000:1000

# copy project
COPY . .

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "blog_app.wsgi:application"]
```

1. build your docker image 
```bash
docker build -t django_blog_app .
```

2. run the docker container
```bash
 docker run \
 -e SECRET_KEY="django-insecure-$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" \
  -p 8000:8000 django_app
```
access your app from your docker container using this url [http://127.0.0.1:8000/]( http://127.0.0.1:8000/)

## Step 2: Build and Push your Django app  Image to AWS ECR. 

1. create a ECR repository: 

```bash
aws ecr create-repository --repository-name django-app --region <REGION> --profile <PROFILE_NAME>
```
2. Authenticate the Docker CLI to use the ECR registry:
```bash
    aws ecr get-login-password --region <REGION>| docker login \
    --username AWS --password-stdin \
    <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
```

3. Build a new  docker image with your AWS account ID: 
```bash
docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/django-app:latest .
```
Be sure to replace <AWS_ACCOUNT_ID> with your AWS account ID.
We'll be using the us-west-1 region throughout this tutorial. Feel free to change this if you'd like.


4. Push the image to ECR:
```bash
    docker push <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/django-app:latest
```
***IMPORTANT***
> Replace <AWS_ACCOUNT_ID> with your AWS account ID.
> Replace <REGION> with your prefered AWS region
> Replace <PROFILE_NAME> with the profile configured with AWS CLI. If you don't specify a profile , the default profile will be used
> We'll be using the us-east-1 region throughout this tutorial. Feel free to change this if you'd like.


## Step 3: Create AWS Ressources using Terraform.
In this third step we will create  our AWS infrastrusture using Terraform. Create  a "terraform" directory in your project's root. This is where We'll be adding all  of our Terraform configuration files.

### 3.1 Project Structure
Create the following directory structure:

```bash
terraform/
├── main.tf
├── variables.tf
├── provider.tf
├── outputs.tf
├── vpc.tf
├── ecs.tf
├── rds.tf
├── alb.tf
├── auto_scaling.tf
└── security_groups.tf
```
AWS resources that we will be creating with Terraform.
| Component           | AWS Service |
| ------------------- | ----------- |
| ECS          | Task Definition,Cluster,Service |
| IAM      | IAM Roles and Policies|
| Database (Optional) | RDS         |
| Networking          | VPC, Public and private subnets, , ALB,SGs,Routing tables,Internet Gateway|
| Security       | Security Groups  |
| Load Balancer     | ALB,Listeners, and Target Groups  |


### 3.2 Configure AWS provider

1. create variables.tf file in the terraform folder and add this details 

```bash
    variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "profile" {
  description = "The AWS profile to use for authentication."
  default     = "default"

}

variable "project_name" {
  description = "The name of the project."
  default     = "DjangoApp"

}
```
2. create provider.tf file in the terraform folder and add this details 
```bash    
        terraform {
        required_providers {
            aws = {
            source = "hashicorp/aws"
            }
        }

        required_version = ">= 1.0"
        }

        provider "aws" {
        region  = var.region
        profile = var.profile
        }
```

***IMPORTANT***
> Feel free to update the variables as you go through this tutorial based on your specific requirements.

Run  `terraform init` command in the `terraform` directory to download the AWS provider plugin. We can now start defining each component  of the AWS infrastructure.


### 3.3 Create Networking Resources
Create a new terraform  configuration file called `network.tf`. In this terraform configuration file, we define the following AWS resources 
    - 1. Virtual Private Cloud (VPC)
    - 2. Public and private subnets
    - 3. Route tables and Route table Associations
    - 4. Internet Gateway
    - 5. NAT gateway
    - 6. AWS Elastic IP
You can checkout the detailed configurations  of all the network  resources in the `networking.tf` file



### 3.3 Create Security Groups ,(SGs)
Create a new terraform configuration file named , `securitygroups.tf`. this terraform configuration file, we define all the SGs that will controll traffic to  the Django app and ECS cluster. The following SGs will be defined.
    - 1. Application Load Balancer (ALB) Security Group 
    - 2. ECS Fargate Security group (defines traffic from the ALB to the -> ECS Fargate Tasks)
    

### 3.4 Create Load Balancer
Next, create new terraform  configuration file called `loadbalancer.tf` we will  configure an  ALB along with the appropriate Target Group and Listener.

### 3.5 Create IAM Roles
In this section we will define 2  IAM roles, `ECS Task Execution role` and `ECS Service role`. The task execution role grants the Amazon ECS container and Fargate agents permission to make AWS API calls on your behalf.
we define the following AWS resources 
    - 1. ECS Task Execution role 
    - 2. ECS Service role
    - 3. ECS task execution role-policy
    - 4. ECS service role-policy  
more detailes in the `iam.tf` terraform configuration  file 

Add a new directory  in the `terraform` directory called `policies`. This directory contains the policies for the IAM roles


### 3.6 Create  CLoudWatch log group
Create a `logs.tf` file and add the bellow terraform configuration 
```bash
        resource "aws_cloudwatch_log_group" "django-log-group" {
    name              = "/ecs/django-app"
    retention_in_days = var.log_retention_in_days
    }
``` 

### 3.7 Create ECS cluster, Task definition and Service
Now it is time to define all the resources for  AWS ECS service  to deploy the app. These are the resouces that will be defined in the `ecs.tf` configuration file.
    - 1. ECS Cluster (a logical grouping of tasks or services)
    - 2. ECS Task definition (Blueprint for our application )
    - 3. ECS Service (run and maintains a specified number of instances of a task definition simultaneously in an  ECS cluster)
    - 4. Template file. 
The task definition file `django_app.json.tpl`is in the  `templates` directory in the `terraform` directory.The task definition  defines the  container definition associated with the Django app.

### 3.8 Create Autoscaling Group , (ASG)
Scalling your resources is important, in this section we will define an auto scaling group to  handle the scaling of ECS task automatically. 
    - 1. AWS Appautoscaling Target
    - 2. AWS Appautoscaling policy  
 The ECS tasks will scale based on their average CPU utilization. When it reaches 75%, more tasks will be started.
## Step 4: Deploy the Infrastructure

## Step 5: Post-Deployment Tasks

## Step 6: Configure Domain and SSL (Optional)

## Step 7: Monitoring and Logging



## ERRORS and Troubleshooting 
ERROR: failed to solve: python:3.12.0-slim-bookworm: failed to resolve source metadata for docker.io/library/python:3.12.0-slim-bookworm: failed to do request: Head "https://registry-1.docker.io/v2/library/python/manifests/3.12.0-slim-bookworm": net/http: TLS handshake timeout

unexpected status from POST request to https://650251710981.dkr.ecr.us-east-1.amazonaws.com/v2/django-app/blobs/uploads/: 404 Not Found