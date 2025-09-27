# Get latest AMI
data "aws_ami" "debian" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [ "" ]
  }
}

# Security Group for web server (Public)
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-${var.environment}-web-"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-server-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for App Servers (Private)
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Web Servers"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    description     = "SSH from Web Servers"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Key pair
resource "tls_private_key" "WebServer_ed25519" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "WebServer_ssh_keys" {
  key_name = var.key_name
  public_key = tls_private_key.WebServer_ed25519.public_key_openssh
}

# Save key on host
resource "local_file" "private_key" {
  content = tls_private_key.WebServer_ed25519.private_key_openssh
  filename = var.key_name
}

resource "aws_instance" "web" {
  count = length(var.public_subnets_ids)

  ami = data.aws_ami.debian.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [ aws_security_group.web.id ]
  user_data = base64encode(
              <<-EOF
                #!/bin/bash
                sudo apt update -y &&
                sudo apt upgrade -y &&
                sudo apt install nginx -y &&
                systemctl start nginx &&
                systemctl enable nginx
                echo "<h1>Web Server ${count.index + 1} - ${var.environment}</h1>" > /var/www/html/index.html
                echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
              EOF
  )

  tags = {
    Name = "${var.project_name}-${var.environment}-web-${count.index + 1}"
    Type = "web"
  }
}

# App Servers (Private Subnets)
resource "aws_instance" "app" {
  count = length(var.private_subnets_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id             = var.privar.private_subnets_ids[count.index]

  user_data = base64encode(<<-EOF
                #!/bin/bash
                sudo apt update -y &&
                sudo apt upgrade -y &&
                sudo apt install python -y
                echo "Starting app server on port 8080" > /var/log/app-startup.log
                python3 -m http.server 8080 &
              EOF
  )

  tags = {
    Name = "${var.project_name}-${var.environment}-app-${count.index + 1}"
    Type = "app"
  }
}





resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.WebServer-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.WebServer-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.WebServer-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_http_traffic_ipv4" {
  security_group_id = aws_security_group.WebServer-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

  ## ipv6 Ingress
  # resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  #   security_group_id = aws_security_group.allow_traffic.id
  #   cidr_ipv6         = "::/0"
  #   from_port         = 443
  #   ip_protocol       = "tcp"
  #   to_port           = 443
  # }

  # resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  #   security_group_id = aws_security_group.allow_traffic.id
  #   cidr_ipv6         = "::/0"
  #   from_port         = 80
  #   ip_protocol       = "tcp"
  #   to_port           = 80
  # }

  # resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  #   security_group_id = aws_security_group.allow_traffic.id
  #   cidr_ipv6         = "::/0"
  #   from_port         = 22
  #   ip_protocol       = "tcp"
  #   to_port           = 22
  # }

  # # Egress all any ports
  # resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  #   security_group_id = aws_security_group.allow_traffic.id
  #   cidr_ipv6         = "::/0"
  #   ip_protocol       = "-1" # equivalent to all protocols
  # }

