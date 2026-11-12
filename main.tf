# -------------------------
# AWS Provider
# -------------------------

provider "aws" {
  region = "us-east-1"
}


# -------------------------
# Find latest Ubuntu AMI
# -------------------------

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}


# -------------------------
# Public Subnet
# -------------------------

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet"
  }
}


# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "terraform-igw"
  }
}


# -------------------------
# Route Table
# -------------------------

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-route-table"
  }
}


# -------------------------
# Route Table Association
# -------------------------

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}


# -------------------------
# Security Group
# -------------------------

resource "aws_security_group" "webSg" {
  name   = "terraform-web-sg"
  vpc_id = aws_vpc.myvpc.id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-web-sg"
  }
}


# -------------------------
# AWS Key Pair
# -------------------------

resource "aws_key_pair" "example" {
  key_name   = "terraform-demo-sajal"
  public_key = file(pathexpand("~/.ssh/terraform_key.pub"))
}


# -------------------------
# EC2 Instance
# -------------------------

resource "aws_instance" "server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.example.key_name

  vpc_security_group_ids = [
    aws_security_group.webSg.id
  ]

  subnet_id = aws_subnet.sub1.id


  # -------------------------
  # SSH Connection
  # -------------------------

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand("~/.ssh/terraform_key"))
    host        = self.public_ip
  }


  # -------------------------
  # Copy app.py to EC2
  # -------------------------

  provisioner "file" {
    source      = "app.py"
    destination = "/home/ubuntu/app.py"
  }


  # -------------------------
  # Install Flask and run app
  # -------------------------

  provisioner "remote-exec" {

    inline = [
      "echo 'Hello from the remote instance'",

      "sudo apt-get update -y",

      "sudo apt-get install -y python3-flask",

      "sudo python3 /home/ubuntu/app.py > /home/ubuntu/app.log 2>&1 &"
    ]
  }


  tags = {
    Name = "terraform-flask-server"
  }
}
