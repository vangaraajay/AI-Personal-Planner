#!/bin/bash
set -e

echo "🚀 Starting AI Personal Planner deployment..."

# --- CONFIG ---
PY_VERSION="3.11"              # Match your Lambda runtime (e.g. python3.11)
LAMBDA_DIR="lambda"
TERRAFORM_DIR="terraform"
ZIP_PATH="${TERRAFORM_DIR}/lambda.zip"
REQUIREMENTS_FILE="${LAMBDA_DIR}/requirements.txt"
REGION="us-east-2"            

# --- STEP 1: Clean old build ---
echo "🧹 Cleaning previous builds..."
rm -f ${ZIP_PATH}

# --- STEP 2: Build Lambda dependencies in Amazon Linux (Docker) ---
echo "📦 Building Lambda deployment package in Amazon Linux (packaging lambda/)..."

# remove any previous build output
rm -rf ./lambda/build_lambda
mkdir -p ./lambda/build_lambda

# copy lambda source files into build folder
cp ./lambda/*.py ./lambda/build_lambda/ 2>/dev/null || true
cp -r ./lambda/handlers ./lambda/build_lambda/ 2>/dev/null || true

# Install dependencies into build folder using the official Lambda Python image
docker run --rm -v $(pwd):/var/task --platform linux/amd64 --entrypoint bash public.ecr.aws/lambda/python:${PY_VERSION} -c "
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --target /var/task/lambda/build_lambda -r /var/task/lambda/requirements.txt
"

# create a zip of the build contents and move it to the Terraform folder
cd ./lambda/build_lambda
zip -r ../../lambda_build.zip ./*
mv ../../lambda_build.zip ../..//${ZIP_PATH}
cd -

# --- STEP 3: Deploy Terraform infrastructure ---
echo "🏗️ Deploying infrastructure with Terraform..."
cd ${TERRAFORM_DIR}
terraform init -input=false
terraform plan -input=false
terraform apply -auto-approve

# --- STEP 4: Get outputs and update .env file ---
echo "⚙️ Updating environment variables..."
API_URL=$(terraform output -raw api_gateway_url)
API_KEY=$(terraform output -raw api_key)
FRONTEND_URL=$(terraform output -raw frontend_url)
S3_BUCKET=$(terraform output -raw s3_bucket_name)
cd ../client

cat > .env << EOF
VITE_API_URL=${API_URL}
VITE_API_KEY=${API_KEY}
EOF

# --- STEP 5: Build and upload frontend ---
echo "🌐 Building and uploading frontend..."
npm install
npm run build
aws s3 sync dist/ s3://${S3_BUCKET}/ --delete --region ${REGION}

cd ..

# --- STEP 6: Done! ---
echo "✅ Deployment complete!"
echo ""
echo "🌍 Your app is available at: ${FRONTEND_URL}"
echo "🔑 API URL: ${API_URL}"
echo ""
echo "⚠️ Note: CloudFront may take 5–15 minutes to fully propagate."
