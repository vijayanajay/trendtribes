# Django Deployment to AWS

This guide explains how to deploy this Django application using AWS services:
- Elastic Beanstalk for application hosting
- RDS for PostgreSQL database
- MemoryDB for Redis caching

## Prerequisites

1. AWS Account with administrative access
2. AWS CLI and EB CLI installed and configured:
   ```bash
   pip install awscli awsebcli
   aws configure
   ```
3. Git repository with your code

## Step-by-Step Deployment Guide

### 1. Set Up Database with RDS

1. **Create PostgreSQL database:**
   - Navigate to RDS in AWS Console
   - Click "Create database"
   - Select PostgreSQL
   - Choose "Dev/Test" or "Production" tier
   - Set DB name, username, and password
   - Under connectivity, create a new VPC security group
   - Make note of the database endpoint, username, password, and port

2. **Set up security group for database access:**
   - Ensure the security group allows inbound traffic on port 5432 from your Elastic Beanstalk security group (we'll create this later)

### 2. Set Up Redis with MemoryDB

1. **Create a Redis cluster:**
   - Navigate to MemoryDB in AWS Console
   - Click "Create cluster"
   - Configure name, node type (t4g.small is smallest)
   - Choose single shard with minimal replicas for development
   - Create or select a subnet group
   - Use the same VPC as your RDS instance
   - Make note of the Redis endpoint

2. **Configure security groups:**
   - Ensure the security group allows inbound traffic on port 6379 from your Elastic Beanstalk security group

### 3. Deploy Django to Elastic Beanstalk

#### Manual Deployment via AWS Console

1. **Create application bundle:**
   ```bash
   # Create deployment package
   zip -r heatmaps.zip . -x "*.git*" "*.venv*" "*.idea*" "*.pyc" "__pycache__/*" "*.env"
   ```

2. **Create Elastic Beanstalk application:**
   - Navigate to Elastic Beanstalk in AWS Console
   - Click "Create Application"
   - Enter application name: "heatmaps"
   - Select Python platform
   - Upload your application bundle (heatmaps.zip)
   - Click "Create application"

3. **Configure environment variables:**
   - From your EB environment, go to Configuration
   - Under "Software", click "Edit"
   - Add environment variables from .env.aws-example file with your actual values

#### Using the Deployment Script

Alternatively, use the provided deployment script:

1. **Make the script executable:**
   ```bash
   chmod +x scripts/deploy-aws.sh
   ```

2. **Edit the script variables:**
   - Open scripts/deploy-aws.sh
   - Update AWS_REGION, VPC settings, etc. to match your environment

3. **Run the deployment script:**
   ```bash
   ./scripts/deploy-aws.sh
   ```

### 4. Post-Deployment Configuration

1. **Create superuser:**
   If you set DJANGO_SUPERUSER_* environment variables, a superuser will be created automatically.
   Otherwise, run:
   ```bash
   eb ssh
   cd /var/app/current
   source /var/app/venv/*/bin/activate
   python manage.py createsuperuser
   ```

2. **Verify services connectivity:**
   - Check RDS connectivity by logging into Django admin
   - Verify Redis connectivity by checking cache operations

## Troubleshooting

### Database Connection Issues
- Ensure the security group allows traffic from Elastic Beanstalk
- Verify environment variables are set correctly
- Check logs: `eb logs`

### Static Files Issues
- If static files aren't loading, verify your STATIC_URL and STATICFILES_DIRS settings
- Consider using S3 for static files

### Redis Connection Issues
- Ensure Redis endpoint and port are correct
- Verify network connectivity between EB and MemoryDB

## Maintenance and Scaling

### Scaling Options
- **Vertical scaling:** Increase instance size in EB environment
- **Horizontal scaling:** Configure auto-scaling in EB environment

### Backup Strategies
- Enable automated backups for RDS
- Configure regular snapshots for MemoryDB
- Implement S3 backup for media files

### Monitoring
- Set up CloudWatch alarms for key metrics
- Configure health checks and notifications

## Security Best Practices

1. Use IAM roles with minimal permissions
2. Enable encryption for RDS and MemoryDB
3. Use HTTPS and configure security headers
4. Store secrets in AWS Secrets Manager
5. Regularly update dependencies and apply security patches 