# Boilerplate---lambda-api-gateway-zip

This Terraform code sets up an AWS Lambda function with an API Gateway. The Lambda function returns a simple message when invoked via the API Gateway. The code also creates an IAM role for the Lambda function, attaches necessary policies, and sets up a default stage for the API Gateway. 

## Prerequisites

- An AWS account with sufficient permissions to create Lambda functions and API Gateways
- Terraform installed on your local machine

## Usage

1. Clone the repository to your local machine:
```console
git clone https://github.com/mterrano1/Boilerplate---terraform-lambda-api-gateway-zip.git
```

2. Navigate to the terraform-lambda-api-boilerplate directory:
```console
cd terraform-lambda-api-boilerplate
```

3. Initialize the Terraform configuration:
```console
terraform init
```

4. Review the configuration files in the `main.tf` and `lambda_function.py` files.

5. Deploy the infrastructure to AWS:
```console
terraform apply
```

6. Wait for the deployment to complete. When it's finished, Terraform will output the URL of the API Gateway.

7. Test the API Gateway by visiting the URL in a web browser or using a tool such as `curl`.

8. When you're finished, tear down the infrastructure:
```console
terraform destroy
```

## Contributing

If you find a bug or have a feature request, please open an issue or submit a pull request.