# AI Personal Planner
(Note: This README was made with AI)

An AI-powered task management application that allows users to manage their personal tasks through natural language conversations using Amazon Bedrock's Claude AI.

## What's Next

This is a project I'm currently still improving on! Here's what I want to work on for later!

- Improve the frontend UI/UX to make it more intuitive and visually appealing  
- Implement a robust authentication system to support multiple users securely

## Features

- **Natural Language Interface**: Add, update, delete, and view tasks using conversational AI
- **Real-time Task Management**: CRUD operations with DynamoDB backend
- **Serverless Architecture**: Built on AWS Lambda, API Gateway, and DynamoDB
- **Secure**: API key authentication and input validation
- **Scalable**: Pay-per-request billing and CloudFront CDN

## Architecture

```
Frontend (React + Vite) → API Gateway → Lambda → DynamoDB
                                    ↓
                              Amazon Bedrock (Claude)
```

## Tech Stack

**Frontend:**
- React 19 with Vite
- Vanilla CSS

**Backend:**
- AWS Lambda (Python 3.11)
- LangChain for AI agent orchestration
- Amazon Bedrock (Claude 3 Haiku)

**Infrastructure:**
- DynamoDB (NoSQL database)
- API Gateway (REST API)
- CloudFront + S3 (Static hosting)
- Terraform (Infrastructure as Code)

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Node.js and npm
- Docker (for production deployment)
- Access to Amazon Bedrock Claude models

## Quick Start

### Option 1: Simple Deployment
```bash
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Deployment with Docker (Recommended)
```bash
chmod +x deploywlambdalayer.sh
./deploywlambdalayer.sh
```

The deployment will:
1. Build Lambda dependencies
2. Deploy AWS infrastructure
3. Build and upload React frontend
4. Configure environment variables
5. Display your app URL

## Usage

Once deployed, you can interact with your AI planner using natural language:

- **Add tasks**: "Add a task to buy groceries due tomorrow"
- **Update status**: "Mark buy groceries as completed"
- **Delete tasks**: "Delete the grocery task"
- **View tasks**: Tasks are automatically displayed on the page

## Project Structure

```
AI-Personal-Planner/
├── client/                 # React frontend
│   ├── src/
│   │   ├── App.jsx        # Main application component
│   │   └── ...
│   └── package.json
├── lambda/                 # Python backend
│   ├── agent.py           # Lambda function with AI agent
│   └── requirements.txt
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # AWS resources
│   ├── outputs.tf         # Terraform outputs
│   └── ...
├── deploy.sh              # Simple deployment script
├── deploywlambdalayer.sh  # Docker-based deployment
└── destroy.sh             # Cleanup script
```

## API Endpoints

- `POST /chat` - Send messages to AI agent
- `GET /tasks` - Retrieve all tasks

Both endpoints require API key authentication via `X-API-Key` header.

## Environment Variables

The deployment scripts automatically configure:
- `VITE_API_URL` - API Gateway endpoint
- `VITE_API_KEY` - API authentication key

## Security Features

- Input validation and sanitization
- API key authentication
- IAM roles with least-privilege access
- Server-side encryption for data at rest
- CORS configuration for browser security

## Cost Optimization

- Serverless architecture (pay-per-use)
- DynamoDB on-demand billing
- CloudFront caching
- API Gateway throttling (100 req/sec)

## Cleanup

To remove all AWS resources:
```bash
chmod +x destroy.sh
./destroy.sh
```

## Troubleshooting

**Common Issues:**
- Ensure AWS CLI is configured with proper permissions
- Bedrock access may need to be enabled in your AWS region
- CloudFront propagation takes 5-15 minutes
- Using certain operating systems may causes errors while using the simple deployment script. In that case, use the docker deployment.

**Logs:**
- Lambda logs: CloudWatch Logs
- API Gateway logs: Enable in AWS Console if needed


## License

This project is for educational purposes.