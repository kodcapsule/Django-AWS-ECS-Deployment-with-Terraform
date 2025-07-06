# Django AWS ECS Deployment with Terraform: Production-Ready Infrastructure Setup


## ✅ Prerequisites
Before starting, ensure you have the following:
- AWS CLI installed and configured with appropriate permissions. [Installing or updating to the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform installed (version v1.5.7). [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Docker installed. [Install Docker Engine](https://docs.docker.com/engine/install/)
- Python (v3.12.0)[https://www.python.org/downloads/](https://www.python.org/downloads/)
- Django ( v4.2.7)
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
[!IMPORTANT]
> Replace <AWS_ACCOUNT_ID> with your AWS account ID.
> Replace <REGION> with your prefered AWS region
> Replace <PROFILE_NAME> with the profile configured with AWS CLI. If you don't specify a profile , the default profile will be used
> We'll be using the us-east-1 region throughout this tutorial. Feel free to change this if you'd like.


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
├── auto_scaling.tf
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



## ERRORS and Troubleshooting 
ERROR: failed to solve: python:3.12.0-slim-bookworm: failed to resolve source metadata for docker.io/library/python:3.12.0-slim-bookworm: failed to do request: Head "https://registry-1.docker.io/v2/library/python/manifests/3.12.0-slim-bookworm": net/http: TLS handshake timeout

unexpected status from POST request to https://650251710981.dkr.ecr.us-east-1.amazonaws.com/v2/django-app/blobs/uploads/: 404 Not Found