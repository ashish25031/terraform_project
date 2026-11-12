This project demonstrates how to use **Terraform as Infrastructure as Code (IaC)** to create AWS infrastructure and deploy a simple Python Flask web application on an EC2 instance.

Instead of manually creating AWS resources through the AWS Management Console, the infrastructure was defined using Terraform in the `main.tf` file.

## Technologies Used

- Terraform
- Amazon Web Services (AWS)
- Amazon EC2
- Amazon VPC
- Internet Gateway
- Route Table
- Security Group
- AWS Key Pair
- Ubuntu 24.04
- Python
- Flask
- Git
- GitHub
- GitHub Codespaces

## Project Architecture

```text
                         Internet
                            |
                            |
                    Internet Gateway
                            |
                            |
                    Public Route Table
                            |
                            |
                    Public Subnet
                    10.0.0.0/24
                            |
                            |
                    EC2 Instance
                      t3.micro
                   Ubuntu 24.04
                            |
                            |
                     Flask Application
                            |
                            |
                  "Hello, Terraform!"
AWS Infrastructure

The following AWS resources were created using Terraform:

VPC
Public Subnet
Internet Gateway
Route Table
Route Table Association
Security Group
EC2 Key Pair
EC2 Instance
1. AWS Provider

Terraform was configured to use AWS as the cloud provider.

The project uses the:

us-east-1

AWS region.

Terraform uses the AWS provider to communicate with AWS and create the infrastructure defined in main.tf.

2. VPC

A Virtual Private Cloud (VPC) was created with the CIDR block:

10.0.0.0/16

The VPC provides an isolated networking environment for our AWS resources.

3. Public Subnet

A public subnet was created inside the VPC.

Subnet CIDR:

10.0.0.0/24

Availability Zone:

us-east-1a

Public IP assignment was enabled for instances launched in this subnet.

The network structure is:

VPC
10.0.0.0/16
    |
    └── Public Subnet
        10.0.0.0/24
4. Internet Gateway

An Internet Gateway was created and attached to the VPC.

The Internet Gateway provides communication between the VPC and the Internet.

The traffic flow is:

EC2
 |
Public Subnet
 |
Internet Gateway
 |
Internet
5. Route Table

A route table was created for the public subnet.

The default route was configured as:

0.0.0.0/0 → Internet Gateway

This means that traffic destined for the Internet is sent through the Internet Gateway.

The route table was associated with the public subnet.

6. Security Group

A security group was created for the EC2 instance.

The following inbound traffic was allowed:

HTTP
Port: 80
Source: 0.0.0.0/0

Port 80 allows users to access the Flask web application through HTTP.

SSH
Port: 22
Source: 0.0.0.0/0

Port 22 allows SSH connections to the EC2 instance.

Outbound traffic was also allowed.

Note: Allowing SSH from 0.0.0.0/0 was used for this learning project. In a production environment, SSH access should normally be restricted to trusted IP addresses.

7. SSH Key Pair

An SSH key pair was generated inside GitHub Codespaces using:

ssh-keygen -t rsa -f ~/.ssh/terraform_key -N ""

This created:

~/.ssh/terraform_key
~/.ssh/terraform_key.pub

The public key was provided to AWS when creating the EC2 key pair.

The private key was used by Terraform to connect to the EC2 instance using SSH.

The key structure was:

terraform_key.pub
        |
        └── Public Key → AWS

terraform_key
        |
        └── Private Key → Used from Codespace
8. Ubuntu AMI

Terraform was configured to dynamically find a suitable Ubuntu 24.04 AMI instead of using an old hardcoded AMI ID.

The AMI was configured for:

Ubuntu 24.04
x86_64 architecture
HVM virtualization
Canonical as the owner

This makes the Terraform configuration more reusable and avoids depending on an outdated AMI ID.

9. EC2 Instance

Terraform created an EC2 instance with the following configuration:

Instance Type: t3.micro
Operating System: Ubuntu 24.04
Region: us-east-1

The EC2 instance was launched inside the public subnet and associated with the security group.

10. Terraform SSH Connection

After the EC2 instance was created, Terraform used SSH to connect to the server.

The connection configuration used:

User: ubuntu
Protocol: SSH
Private Key: terraform_key
Host: EC2 Public IP

This allowed Terraform to execute commands and copy files directly to the EC2 instance.

11. File Provisioner

Terraform's file provisioner was used to copy the Flask application from the GitHub Codespace to the EC2 instance.

The source file was:

app.py

The destination was:

/home/ubuntu/app.py

The process was:

GitHub Codespace
       |
       ↓
Terraform File Provisioner
       |
       ↓
EC2 Instance
       |
       ↓
/home/ubuntu/app.py
12. Remote-Exec Provisioner

Terraform's remote-exec provisioner was used to execute commands on the EC2 instance.

The commands performed the following tasks:

Updated the Ubuntu package repository.
Installed Flask.
Started the Flask application.

Flask was installed using:

sudo apt-get update -y
sudo apt-get install -y python3-flask

The Flask application was then started on the EC2 instance.

13. Flask Application

The Flask application is stored in:

app.py

The application contains a root route:

/

When a user accesses the application, it returns:

Hello, Terraform!

The Flask server listens on:

0.0.0.0:80

This allows the application to receive HTTP requests through the EC2 instance's public IP address.

Application Request Flow
User Browser
     |
     ↓
EC2 Public IP
     |
     ↓
Security Group
     |
     ↓
Port 80
     |
     ↓
Flask Application
     |
     ↓
Hello, Terraform!
14. Terraform Workflow

The project followed the standard Terraform workflow.

Initialize Terraform
terraform init

This initializes the Terraform working directory and downloads the required Terraform provider.

Validate Terraform Configuration
terraform validate

This checks whether the Terraform configuration is syntactically valid.

Create Terraform Plan
terraform plan

Terraform creates an execution plan showing the resources that will be created, changed, or destroyed.

The plan showed:

Plan: 8 to add, 0 to change, 0 to destroy.
Apply Terraform Configuration
terraform apply

This command creates the infrastructure in AWS according to the Terraform configuration.

Terraform successfully created the required AWS resources and connected to the EC2 instance using SSH.

15. Testing the EC2 Instance

After the EC2 instance was created, we connected to it using SSH:

ssh -i ~/.ssh/terraform_key ubuntu@<EC2-PUBLIC-IP>

The application file was available on the server at:

/home/ubuntu/app.py

This confirmed that Terraform successfully copied the Flask application to the EC2 instance.

16. Git and GitHub

After completing the project, the important source files were added to Git:

git add main.tf app.py .terraform.lock.hcl

A Git commit was created using:

git commit -m "Add Terraform AWS Flask project"

The project was then pushed to GitHub using:

git push

The GitHub repository contains the main project files:

terraform_project/
│
├── .terraform.lock.hcl
├── README.md
├── app.py
└── main.tf
17. Files Not Committed to GitHub

Some generated and local files were intentionally not added to GitHub:

.terraform/
aws/
awscliv2.zip
terraform.tfstate

The Terraform state file was not committed because it can contain sensitive infrastructure information.

The .terraform directory contains downloaded provider files and does not need to be stored in the source repository.

Therefore, only the important project source files were committed to GitHub.

18. Infrastructure as Code

This project demonstrates the concept of Infrastructure as Code (IaC).

Infrastructure as Code means defining cloud infrastructure using code instead of manually creating resources through a graphical interface.

For example, instead of manually creating:

VPC
Subnet
Internet Gateway
Route Table
Security Group
EC2 Instance

we define them in Terraform.

Terraform then creates the infrastructure automatically.

19. Complete Project Flow
Write Terraform Configuration
            |
            ↓
       terraform init
            |
            ↓
     terraform validate
            |
            ↓
       terraform plan
            |
            ↓
      terraform apply
            |
            ↓
    AWS Infrastructure
        Created
            |
            ↓
      EC2 Instance
        Created
            |
            ↓
    SSH Connection
            |
            ↓
     Copy app.py
            |
            ↓
     Install Flask
            |
            ↓
    Start Flask App
            |
            ↓
   Access through Port 80
            |
            ↓
   "Hello, Terraform!"
20. Final Result

The project successfully demonstrated how Terraform can be used to automate AWS infrastructure creation and basic application deployment.

Terraform was used to:

Create a VPC.
Create a public subnet.
Create an Internet Gateway.
Create a route table.
Configure network routing.
Create a security group.
Create an SSH key pair.
Launch a t3.micro EC2 instance.
Use Ubuntu 24.04 as the operating system.
Connect to the EC2 instance using SSH.
Copy the Flask application to the EC2 instance.
Install Flask.
Start the Flask web application.
Store the project source code in GitHub.
Conclusion

This project provided practical experience with Terraform, AWS, Infrastructure as Code, EC2, VPC networking, security groups, SSH, Python Flask, Git, and GitHub.

The main learning from this project is that cloud infrastructure can be defined as code and created automatically using Terraform.

Instead of manually configuring AWS resources, Terraform provides a repeatable and automated way to provision infrastructure.

The project also demonstrated how Terraform provisioners can be used to copy application files and execute commands on a newly created EC2 instance.
