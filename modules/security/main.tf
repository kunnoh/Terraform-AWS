# Generate private key
resource "tls_private_key" "WebServer_ed25519" {
  algorithm = "ED25519"
    
  # Lifecycle management for security
  lifecycle {
    prevent_destroy = true # Prevent accidental deletion
    # create_before_destroy = true # Create new key before destroying old one (zero-downtime rotation)
    # ignore_changes = [ # Ignore changes to prevent drift
    #   # Don't recreate on minor provider updates
    # ]
  }
}

# Create AWS key pair
resource "aws_key_pair" "main" {
  key_name = "${var.project_name}-${var.environment}-key"
  public_key = tls_private_key.WebServer_ed25519.public_key_openssh
  
  tags = {
    Name = "${var.project_name}-${var.environment}-keypair"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Save key on host
resource "local_file" "private_key" {
  count = var.save_private_key_locally ? 1 : 0
  
  content = tls_private_key.WebServer_ed25519.private_key_openssh
  filename = "${path.module}/../../keys/${var.project_name}-${var.environment}-key.pem"
  file_permission = "0600"

  lifecycle {
    create_before_destroy = true
  }
}

# # Secure storage in AWS systems manager parameter store
# resource "aws_ssm_parameter" "private_key" {
#   name  = "/${var.project_name}/${var.environment}/webserver/private-key"
#   type  = "SecureString"
#   value = tls_private_key.webserver_ed25519.private_key_pem
  
#   # Use customer-managed KMS key for enhanced security
#   key_id = aws_kms_key.webserver_key_encryption.arn
  
#   description = "ED25519 private key for ${var.project_name} webserver in ${var.environment}"
  
#   tags = merge(local.common_tags, {
#     KeyType     = "ED25519"
#     Purpose     = "WebServer-SSH"
#     Sensitive   = "true"
#   })
  
#   lifecycle {
#     ignore_changes = [value]
#   }
# }

# resource "aws_ssm_parameter" "public_key" {
#   name  = "/${var.project_name}/${var.environment}/webserver/public-key"
#   type  = "String"
#   value = tls_private_key.webserver_ed25519.public_key_openssh
  
#   description = "ED25519 public key for ${var.project_name} webserver in ${var.environment}"
  
#   tags = merge(local.common_tags, {
#     KeyType   = "ED25519"
#     Purpose   = "WebServer-SSH"
#     Sensitive = "false"
#   })
# }

locals {
  # Common tags applied to all resources
  common_tags = {
    Environment     = var.environment
    Project        = var.project_name
    ManagedBy      = "Terraform"
    SecurityLevel  = "High"
    KeyAlgorithm   = "ED25519"
    CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
    # RotationDue    = formatdate("YYYY-MM-DD", timeadd(timestamp(), "${var.key_rotation_days * 24}h"))
  }
}