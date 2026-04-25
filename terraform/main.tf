# ─────────────────────────────────────────────────────────────
# main.tf  —  Core AWS infrastructure for the microservices app
# ─────────────────────────────────────────────────────────────

# ── 1. VPC ───────────────────────────────────────────────────
# A VPC (Virtual Private Cloud) is your own private network on AWS.
# Think of it as the walls of your building — everything lives inside.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"   # IP range: allows up to 65,536 addresses
  enable_dns_hostnames = true             # Allows EC2 instances to get DNS names
  enable_dns_support   = true

  tags = {
    Name = "microservices-vpc"
  }
}

# ── 2. Internet Gateway ───────────────────────────────────────
# The "front door" of your VPC — allows traffic in/out from the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id   # Attach it to our VPC

  tags = {
    Name = "microservices-igw"
  }
}

# ── 3. Public Subnet ──────────────────────────────────────────
# A subnet is a section of your VPC.
# "Public" means resources here can be reached from the internet.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"        # Subset of the VPC's IP range
  availability_zone       = "${var.aws_region}a"  # e.g. us-east-1a
  map_public_ip_on_launch = true                  # EC2 gets a public IP automatically

  tags = {
    Name = "microservices-public-subnet"
  }
}

# ── 4. Route Table ────────────────────────────────────────────
# A route table tells traffic WHERE to go.
# This one sends all internet-bound traffic to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                        # "all traffic"
    gateway_id = aws_internet_gateway.main.id        # → send to internet gateway
  }

  tags = {
    Name = "microservices-public-rt"
  }
}

# Associate the route table with our subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── 5. Security Group ─────────────────────────────────────────
# A Security Group is a firewall for your EC2 instance.
# You define which ports are open (ingress = incoming, egress = outgoing).
resource "aws_security_group" "ec2_sg" {
  name        = "microservices-sg"
  description = "Security group for the microservices EC2 instance"
  vpc_id      = aws_vpc.main.id

  # Allow SSH — so you can log into the server (port 22)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # ⚠️ In production, restrict this to your IP
  }

  # Allow HTTP — so users can access the app in their browser (port 80)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS — secure browser traffic (port 443)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ArgoCD web UI (port 8080)
  ingress {
    description = "ArgoCD"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (so the server can download packages, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # "-1" means ALL protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "microservices-sg"
  }
}

# ── 6. SSH Key Pair ───────────────────────────────────────────
# To log into EC2 via SSH, AWS needs your public key.
# We reference a key you generate locally (see README).
resource "aws_key_pair" "deployer" {
  key_name   = "microservices-key"
  public_key = file(var.public_key_path)   # reads from your local machine
}

# ── 7. EC2 Instance ───────────────────────────────────────────
# This is the actual server where your app will run.
resource "aws_instance" "app_server" {
  ami                    = var.ami_id            # OS image (Ubuntu 22.04)
  instance_type          = var.instance_type     # Hardware size (e.g. t3.medium)
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # Disk size — Kubernetes + Docker need decent space
  root_block_device {
    volume_size = 30          # 30 GB
    volume_type = "gp3"       # General purpose SSD
  }

  tags = {
    Name = "microservices-app-server"
  }
}
