# Terraform Web Server (AWS)
Deploy a public web server in AWS using terraform.


A quick template for me (and maybe you) to snag as a basis for building terraform things. This launches an Ubuntu server running apache!

## Running
1. Download required dependencies with `terraform init`.
2. Create a deployment with `terraform apply`.

## Cleaning Up
To tear down a created deployment, run `terraform destroy`

## Considerations
This example uses environment variables for secrets. 

You should probably use something else, check out [Yevgeniy Brikman
's blog on Gruntwork](https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1) for some more thorough security techniques.