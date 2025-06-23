# Django AWS ECS Deployment with Terraform: Production-Ready Infrastructure Setup


## ✅ Prerequisites
Before starting, ensure you have the following:
- AWS CLI installed and configured with appropriate permissions
- Terraform installed (version v1.5.7)
- Docker installed
- Python (v3.12.0)
- Django ( v4.2.7)
- Basic understanding of AWS services (VPC, ECS, RDS, ALB)

## Project Architecture diagram

## Project Structure

```bash
├── .gitignore
└── app
    ├── Dockerfile
    ├── blog_app
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    ├── manage.py
    └── requirements.txt
```

## Tech Stack

| Component           | AWS Service |
| ------------------- | ----------- |
| Containers          | ECS Fargate |
| Image Storage       | ECR         |
| Database (Optional) | RDS         |
| Networking          | VPC, ALB,SGs|
| Infra as Code       | Terraform   |
| Monitoring and Logging      | CloudWatch   |

## Step 1: Prepare Your Django Application


 
1. Create a vitual environment 
```bash
    python -m venv env
```

2. activate the  vitual environment 
```bash
    source env/Scripts/activate
```

3. Create a directory for your app
```bash
    mkdir app && cd app
```

4. Install Django
```bash
    pip install django
```
5. Create a django blog app
```bash
    django-admin startproject blog_app .
```
6. start the app and access the app using this url [blog app]( http://127.0.0.1:8000/)
```bash
    django-admin startproject blog_app .
```

## Step 2: Build and Push Docker Image to ECR
1. Build the docker image 
```bash
docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/django-app:latest .
```

Be sure to replace <AWS_ACCOUNT_ID> with your AWS account ID.
We'll be using the us-west-1 region throughout this tutorial. Feel free to change this if you'd like.

2. Authenticate the Docker CLI to use the ECR registry:
```bash
    aws ecr get-login-password --region <REGION>| docker login \
    --username AWS --password-stdin \
    <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
```

3. Push the image:
```bash
    docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/django-app:latest
```

## Step 3: Create Terraform Infrastructure

### 3.1 Project Structure
Create the following directory structure:

```bash
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── vpc.tf
├── ecs.tf
├── rds.tf
├── alb.tf
├── s3.tf
└── security_groups.tf
```
| Component           | AWS Service |
| ------------------- | ----------- |
| ECS          | Task Definition,Cluster,Service |
| IAM      | IAM Roles and Policies|
| Database (Optional) | RDS         |
| Networking          | VPC, Public and private subnets, , ALB,SGs,Routing tables,Internet Gateway|
| Security       | Security Groups  |
| Load Balancer     | ALB,Listeners, and Target Groups  |

## Step 4: Deploy the Infrastructure

## Step 5: Post-Deployment Tasks

## Step 6: Configure Domain and SSL (Optional)

## Step 7: Monitoring and Logging