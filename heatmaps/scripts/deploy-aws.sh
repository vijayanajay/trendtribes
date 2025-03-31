#!/bin/bash
# AWS Deployment Script for Django

# Exit on error
set -e

# Variables (customize these)
APP_NAME="heatmaps"
ENVIRONMENT="production"
AWS_REGION="us-east-1" # Change to your region
EB_PLATFORM="Python 3.11"

# Check for AWS CLI and EB CLI
command -v aws >/dev/null 2>&1 || { echo "AWS CLI required. Install with: pip install awscli"; exit 1; }
command -v eb >/dev/null 2>&1 || { echo "EB CLI required. Install with: pip install awsebcli"; exit 1; }

echo "=== Preparing deployment package ==="

# Create a source bundle
if [ ! -d "deployment" ]; then
  mkdir deployment
fi

# Remove previous package if exists
if [ -f "deployment/${APP_NAME}.zip" ]; then
  rm deployment/${APP_NAME}.zip
fi

# Create deployment package
echo "Creating deployment package..."
zip -r deployment/${APP_NAME}.zip . -x "*.git*" "*.venv*" "*.idea*" "deployment/*" "*.pyc" "__pycache__/*" "*.env" "*.DS_Store"

# Initialize EB if needed
if [ ! -d ".elasticbeanstalk" ]; then
  echo "=== Initializing Elastic Beanstalk ==="
  eb init ${APP_NAME} --region ${AWS_REGION} --platform "${EB_PLATFORM}"
fi

# Create environment if it doesn't exist
if ! eb list | grep -q ${ENVIRONMENT}; then
  echo "=== Creating Elastic Beanstalk environment ==="
  eb create ${ENVIRONMENT} \
    --database \
    --database.engine postgres \
    --database.instance db.t3.micro \
    --database.password $(openssl rand -base64 12) \
    --database.size 5 \
    --instance-type t2.micro \
    --service-role aws-elasticbeanstalk-service-role \
    --elb-type application \
    --vpc.id vpc-xxxxxxxx \
    --vpc.ec2subnets subnet-xxxxxxxx,subnet-yyyyyyyy \
    --vpc.elbsubnets subnet-xxxxxxxx,subnet-yyyyyyyy \
    --vpc.securitygroups sg-xxxxxxxx
else
  echo "=== Deploying to existing environment ==="
  eb deploy ${ENVIRONMENT} --staged
fi

echo "=== Deployment complete ==="
echo "Your application should be accessible at:"
eb status ${ENVIRONMENT} | grep CNAME 